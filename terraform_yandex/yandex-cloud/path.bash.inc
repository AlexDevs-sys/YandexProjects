cli_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_path="${cli_dir}/bin"
export PATH="${bin_path}:${PATH}"
