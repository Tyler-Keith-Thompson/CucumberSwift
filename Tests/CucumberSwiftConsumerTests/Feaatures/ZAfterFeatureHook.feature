Feature: After feature hook test
Can't test the after feature hook until after a feature, so we need a new one!

    Scenario: After feature hook works
        Given I have an after feature hook
        When I run the tests
        Then AfterFeature gets called once per feature
