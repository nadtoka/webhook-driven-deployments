#!/usr/bin/env ruby
require 'json'
require 'net/http'
require 'uri'
require 'openssl'

vault_addr = ENV.fetch('VAULT_ADDR', nil)
vault_token = ENV.fetch('VAULT_TOKEN', nil)
vault_secret = ENV.fetch('VAULT_SECRET', nil)
ssl_verify = ENV.fetch('VAULT_SSL_VERIFY', 'true').downcase != 'false'

if [vault_addr, vault_token, vault_secret].any?(&:nil?)
  warn 'VAULT_ADDR, VAULT_TOKEN, and VAULT_SECRET must be set to use this script.'
  exit 1
end

uri = URI.join(vault_addr, "/v1/#{vault_secret}")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = uri.scheme == 'https'
http.verify_mode = ssl_verify ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE

req = Net::HTTP::Get.new(uri.request_uri)
req['X-Vault-Token'] = vault_token

res = http.request(req)
unless res.is_a?(Net::HTTPSuccess)
  warn "Vault request failed: #{res.code} #{res.message}"
  exit 1
end

data = JSON.parse(res.body)
secret_data = data.dig('data', 'data') || data['data']
ssh_host = secret_data['SSH_HOST']
ssh_user = secret_data['SSH_USER']
ssh_port = secret_data['SSH_PORT'] || 22
ssh_key = secret_data['SSH_KEY']
ssh_key_path = File.expand_path('../id_rsa', __dir__)

unless ssh_host && ssh_user && ssh_key
  warn 'Secret missing required fields: SSH_HOST, SSH_USER, SSH_KEY'
  exit 1
end

File.write(ssh_key_path, ssh_key)
File.chmod(0600, ssh_key_path)

env_path = File.expand_path('../.env', __dir__)
File.open(env_path, 'w') do |f|
  f.puts "export SSH_HOST=#{ssh_host}"
  f.puts "export SSH_USER=#{ssh_user}"
  f.puts "export SSH_PORT=#{ssh_port}"
  f.puts "export SSH_KEY_PATH=#{ssh_key_path}"
end

puts "Wrote #{env_path} and SSH key at #{ssh_key_path}"
