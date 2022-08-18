BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "ContainerStack" {
    It "Generates well-formatted YAML" {
        $output = ContainerStack `
            -Image "image" `
            -EnvFile "envFile" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
        | ConvertFrom-Yaml
        $output | Should -Not -Be $null
        $output.version | Should -Be "3.7"
        $container = $output.services.container
        $container.image | Should -Be "image"
        $container.env_file | Should -Be "envFile"
        $container.logging.driver | Should -Be "splunk"
        $container.logging.options["splunk-token"] | Should -Be "token"
        $container.logging.options["splunk-url"] | Should -Be "splunk.com"
        $container.logging.options["splunk-index"] | Should -Be "idx"
        $container.deploy.resources.limits.cpus | Should -Be "0.25"
        $container.deploy.resources.limits.memory | Should -Be "256M"
    }

    It "Includes ports if configured" {
        $output = ContainerStack `
            -Image "image" `
            -EnvFile "envFile" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -TaskPort "4000" `
        | ConvertFrom-Yaml
        $output.services.container.ports | Should -HaveCount 1
        $output.services.container.ports[0] | Should -Contain "4000:4000"
    }
}
