mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))

generatesecrets gs:
	@ ${current_dir}/security-artifacts/generate-security-artifacts.sh
