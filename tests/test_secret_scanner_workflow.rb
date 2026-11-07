# SPDX-License-Identifier: MPL-2.0

require 'minitest/autorun'
require 'yaml'

class SecretScannerWorkflowTest < Minitest::Test
    WORKFLOW_PATH = File.expand_path('../.github/workflows/secret-scanner.yml', __dir__)
    SCANNER_WORKFLOW = %r{\Ahyperpolymath/standards/\.github/workflows/secret-scanner-reusable\.yml@[0-9a-f]{40}\z}

    def setup
        @workflow = YAML.load_file(WORKFLOW_PATH)
        @scan = @workflow.fetch('jobs').fetch('scan')
    end

    def test_scan_calls_the_pinned_shared_scanner
        assert_match SCANNER_WORKFLOW, @scan.fetch('uses')
    end

    def test_scan_does_not_forward_caller_secrets
        refute @scan.key?('secrets'), 'The scanner must not inherit or receive caller secrets'
    end

    def test_workflow_token_is_limited_to_reading_contents
        assert_equal({ 'contents' => 'read' }, @workflow.fetch('permissions'))
    end

    def test_scan_does_not_override_token_permissions
        refute @scan.key?('permissions'), 'The scanner must use the workflow permissions'
    end
end
