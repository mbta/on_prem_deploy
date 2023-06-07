BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "ContainerStack" {
    It "Generates well-formatted YAML" {
        $rawOutput = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx"
        $output = $rawOutput | ConvertFrom-Yaml
        $output | Should -Not -Be $null
        $output.version | Should -Be "3.9"
        $container = $output.services.container
        $container.image | Should -Be "image"
        $rawOutput | Should -Not -Match "environment:"
        $rawOutput | Should -Not -Match "ports:"
        $container.logging.driver | Should -Be "splunk"
        $container.logging.options["splunk-token"] | Should -Be "token"
        $container.logging.options["splunk-url"] | Should -Be "splunk.com"
        $container.logging.options["splunk-index"] | Should -Be "idx"
        $container.logging.options["splunk-source"] | Should -Be "service-test"
        $container.deploy.placement.max_replicas_per_node | Should -Be 1
        $container.deploy.update_config.order | Should -Be "stop-first"
        $container.deploy.rollback_config.order | Should -Be "stop-first"
        $container.deploy.resources.limits.cpus | Should -Be "0.25"
        $container.deploy.resources.limits.memory | Should -Be "256M"
        $rawOutput | Should -Not -Match "constraints:"
    }

    It "Includes ports if configured" {
        $output = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -TaskPort "4000" `
        | ConvertFrom-Yaml
        $output.services.container.ports | Should -HaveCount 1
        $output.services.container.ports[0].mode | Should -Be "ingress"
        $output.services.container.ports[0].target | Should -Be 4000
        $output.services.container.ports[0].published | Should -Be 4000
    }

    It "Includes multiple ports on separate lines" {
        $output = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -TaskPort "4000 5000" `
        | ConvertFrom-Yaml
        $output.services.container.ports | Should -HaveCount 2
        $output.services.container.ports[0].mode | Should -Be "ingress"
        $output.services.container.ports[0].target | Should -Be 4000
        $output.services.container.ports[0].published | Should -Be 4000
        $output.services.container.ports[1].mode | Should -Be "ingress"
        $output.services.container.ports[1].target | Should -Be 5000
        $output.services.container.ports[1].published | Should -Be 5000
    }

    It "Can override the port mode" {
        $output = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -TaskPort "4000" `
            -PortMode "host" `
        | ConvertFrom-Yaml
        $output.services.container.ports | Should -HaveCount 1
        $output.services.container.ports[0].mode | Should -Be "host"
        $output.services.container.ports[0].target | Should -Be 4000
        $output.services.container.ports[0].published | Should -Be 4000
    }

    It "Includes environment variables if provided" {
        $output = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -Environment @{
            KEY  = "value`nvalue2"
            KEY2 = "single line value"
        } `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
        | ConvertFrom-Yaml
        $output | Should -Not -Be $null
        $container = $output.services.container
        $container.environment.KEY | Should -Be "value`nvalue2"
        $container.environment.KEY2 | Should -Be "single line value"
    }

    It "Can use environment variables converted from JSON" {
        $jsonParsed = @"
{"KEY": "value\nvalue2"}
"@ | ConvertFrom-Json
        $output = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -Environment $jsonParsed.psobject.Properties `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
        | ConvertFrom-Yaml
        $output | Should -Not -Be $null
        $container = $output.services.container
        $container.environment.KEY | Should -Be "value`nvalue2"
    }

    It "Can use environment variables with nested JSON" {
        $jsonParsed = @"
{"KEY": "[{\"object\": \"value\"}]"}
"@ | ConvertFrom-Json
        $output = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -Environment $jsonParsed.psobject.Properties `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
        | ConvertFrom-Yaml
        $output | Should -Not -Be $null
        $container = $output.services.container
        $container.environment.KEY | Should -Be "[{`"object`": `"value`"}]"
    }

    It "Does not include an environment key when provided empty JSON" {
        $jsonParsed = "{}" | ConvertFrom-Json
        $rawOutput = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -Environment $jsonParsed.psobject.Properties `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx"
        $rawOutput | Should -Not -Match "environment:"
    }

    It "Includes 1 additional max_replicas_per_node with start-first order" {
        $rawOutput = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -UpdateOrder "start-first"
        $output = $rawOutput | ConvertFrom-Yaml
        $container = $output.services.container
        $container.deploy.update_config.order | Should -Be "start-first"
        $container.deploy.rollback_config.order | Should -Be "start-first"
        $container.deploy.placement.max_replicas_per_node | Should -Be 2
    }

    It "can increase the number of replicas" {
        $rawOutput = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -Replicas "2"
        $output = $rawOutput | ConvertFrom-Yaml
        $container = $output.services.container
        $container.deploy.replicas | Should -Be 2
        $container.deploy.placement.max_replicas_per_node | Should -Be 1
    }
    
    It "ignores blank replica" {
        $rawOutput = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -Replicas ""
        $output = $rawOutput | ConvertFrom-Yaml
        $container = $output.services.container
        $container.deploy.replicas | Should -Be 1
    }

    It "can set a placement constraint" {
        $rawOutput = ContainerStack `
            -Service "service-test" `
            -Image "image" `
            -SplunkToken "token" `
            -SplunkUrl "splunk.com" `
            -SplunkIndex "idx" `
            -PlacementConstraint "node.hostname == HOSTNAME"
        $output = $rawOutput | ConvertFrom-Yaml
        $container = $output.services.container
        $container.deploy.placement.constraints | Should -HaveCount 1
        $container.deploy.placement.constraints[0] | Should -Be "node.hostname == HOSTNAME"
    }
}
