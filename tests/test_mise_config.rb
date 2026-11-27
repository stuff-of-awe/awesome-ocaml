# SPDX-License-Identifier: MPL-2.0

require 'minitest/autorun'
require 'open3'

class MiseConfigTest < Minitest::Test
    CONFIG_PATH = File.expand_path('../mise.toml', __dir__)
    REMOVED_TOOLS = %w[
        node python go java npm yarn pip make gofmt black isort ruff
        pytest jest vitest prettier eslint
    ].freeze
    RETAINED_TOOLS = %w[
        rust zig bun deno pnpm just shfmt stylua cmake ninja
    ].freeze

    # Ask mise to parse the actual file, without loading other local configs.
    def config_get(key)
        Open3.capture3('mise', '--no-config', 'config', 'get', '--file', CONFIG_PATH, key)
    end

    def test_removed_tools_are_not_declared
        REMOVED_TOOLS.each do |tool|
            _output, error, status = config_get("tools.#{tool}")
            refute status.success?, "#{tool} must not be declared in mise.toml"
            assert_includes error, "Key not found: tools.#{tool}", "Could not inspect #{tool}: #{error}"
        end
    end

    def test_retained_tools_keep_their_versions
        RETAINED_TOOLS.each do |tool|
            output, error, status = config_get("tools.#{tool}")
            assert status.success?, "Could not inspect #{tool}: #{error}"
            assert_equal 'latest', output.strip, "Unexpected version for #{tool}"
        end
    end

    def test_node_and_python_environment_defaults_are_absent
        output, error, status = config_get('env')
        assert status.success?, "Could not inspect environment: #{error}"

        # mise emits parsed TOML, so historical examples in comments do not count.
        refute_match(/^\s*['"]?(?:NODE_ENV|PYTHON[^'"\s=]*)['"]?\s*=/, output)
    end
end
