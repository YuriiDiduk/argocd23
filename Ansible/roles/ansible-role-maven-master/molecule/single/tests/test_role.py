import pytest


def test_mvn(host):
    assert '3.8.5' in host.check_output('mvn --version')


def test_mvn_debug(host):
    assert host.run('which mvnDebug').rc == 0


@pytest.mark.parametrize('command,version_dir_pattern', [
    ('mvn', 'apache-maven-3\\.8\\.[0-9]+$'),
    ('mvnDebug', 'apache-maven-3\\.8\\.[0-9]+$')
])
def test_commands_installed(host, command, version_dir_pattern):

    maven_home = host.check_output('find %s | grep --color=never -E %s',
                                   '/opt/maven',
                                   version_dir_pattern)

    command_file = host.file(maven_home + '/bin/' + command)

    assert command_file.exists
    assert command_file.is_file
    assert command_file.user == 'root'
    assert command_file.group == 'root'
    assert oct(command_file.mode) == '0o755'


def test_facts_installed(host):
    fact_file = host.file('/etc/ansible/facts.d/maven.fact')

    assert fact_file.exists
    assert fact_file.is_file
    assert fact_file.user == 'root'
    assert fact_file.group == 'root'
    assert oct(fact_file.mode) == '0o644'
