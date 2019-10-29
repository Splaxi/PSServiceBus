[CmdletBinding()]
param (
    [Parameter()]
    [PSServiceBus.Tests.Utils.ServiceBusUtils]
    $ServiceBusUtils
)

Describe "Get-SbSubscription tests" {

    # setup

    # create some topics and subscriptions
    $topicsToCreate = 2
    $subscriptionsToCreatePerTopic = 2

    $topics = @()

    $ServiceBusUtils.CreateTopics($topicsToCreate) | ForEach-Object -Process {

        $topic = [PSCustomObject]@{
            TopicName = $_
            Subscriptions = $ServiceBusUtils.CreateSubscriptions($_, $subscriptionsToCreatePerTopic)
        }

        $topics += $topic
    }

    Start-Sleep -Seconds 5

    # send some messages to each topic and dead letter a portion
    $messagesToSendToEachQueue = 5
    $messagesToDeadLetter = 2

    foreach ($topic in $topics)
    {
        for ($i = 0; $i -lt $messagesToSendToEachQueue; $i++)
        {
            $ServiceBusUtils.SendTestMessage($topic.TopicName)
        }

        foreach ($subscription in $topic.Subscriptions)
        {
            $subscriptionPath = $ServiceBusUtils.BuildSubscriptionPath($topic.TopicName, $subscription)

            for ($i = 0; $i -lt $messagesToDeadLetter; $i++)
            {
                $ServiceBusUtils.ReceiveAndDeadLetterAMessage($subscriptionPath)
            }
        }
    }

    # prepare some test cases 

    $testCases = @()
    foreach ($topic in $topics)
    {
        $testCases += @{
            TopicName = $topic.TopicName
            Subscriptions = $topic.Subscriptions
        }
    }

    # tests

    Context "Pipeline input tests" {

        $result = $topics | Get-SbSubscription -NamespaceConnectionString $ServiceBusUtils.NamespaceConnectionString

        It "should return results for each TopicName piped in" -TestCases $testCases {
            param ([string] $topicName)
            $topicName | Should -BeIn $result.Topic
        }
    }

    Context "Test without -SubscriptionName parameter" {
        
        It "should return all of the subscriptions in a topic" {
            
        }

        It "should return the correct number of active messages in all subscriptions" {

        }

        It "should return the correct number of dead lettered messages in all subscriptions" {

        }
    }

    Context "Tests with -SubscriptionName parameter" {

        It "should return the correct subscription" {

        }

        It "should return the correct number of active messages in a specific subscription" {

        }

        It "should return the correct number of dead lettered messages in a specific subscription" {

        }
    }

    # tear down queues created for test

    foreach ($item in $topics)
    {
        $ServiceBusUtils.RemoveTopic($item.TopicName)
    }
}


