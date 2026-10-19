require 'spec_helper'
describe 'dovecot' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('dovecot') }
      end

      context 'with Dovecot 2.4 version settings and an alphabetically earlier key' do
        let(:params) do
          {
            config: {
              'base_dir' => '/var/run/dovecot',
              'dovecot_config_version' => '2.4.0',
              'dovecot_storage_version' => '2.4.2',
              'hostname' => 'mail.example.com',
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        # The version settings must sort before every other top-level setting,
        # because Dovecot 2.4 requires dovecot_config_version to come first.
        it {
          is_expected.to contain_concat__fragment('dovecot /etc/dovecot/dovecot.conf config / 01 dovecot_config_version 02')
            .with_content("dovecot_config_version = 2.4.0\n")
        }
        it {
          is_expected.to contain_concat__fragment('dovecot /etc/dovecot/dovecot.conf config / 01 dovecot_storage_version 02')
            .with_content("dovecot_storage_version = 2.4.2\n")
        }
        it { is_expected.to contain_concat__fragment('dovecot /etc/dovecot/dovecot.conf config / 02 base_dir 02') }
      end

      context 'with Dovecot 2.4 style sections' do
        let(:params) do
          {
            configs: {
              '10-auth' => {
                'passdb passwd-file' => {
                  'driver' => 'passwd-file',
                  'passwd_file_path' => '/etc/dovecot/virtual_accounts_passwd',
                },
              },
              '20-lmtp' => {
                'protocol lmtp' => {
                  'mail_plugins' => { 'sieve' => true },
                },
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('dovecot /etc/dovecot/conf.d/20-lmtp.conf config / 03 protocol lmtp 03 mail_plugins 02 sieve 02')
            .with_content("    sieve = yes\n")
        }
      end
    end
  end
end
