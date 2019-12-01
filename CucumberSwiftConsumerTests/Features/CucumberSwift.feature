Feature: CucumberSwift Library
The CucumberSwift library needs to work like Developers, QAs and Product Owners expect it to
This particular test pulls in the library much like they would and ensures it behaves
as expected

    Scenario: Before feature hook works correctly
        Given I have a before feature hook
        When I run the tests
        Then BeforeFeature gets called once per feature

    Scenario Outline: Before <scn> hook works correctly
        Given I have a before <scn> hook
        When I run the tests
        Then BeforeScenario gets called once per scenario

    Examples:
    |        scn       |
    | scenario outline |

    Scenario: Before scenario outline hook works correctly
        Given I have a before scenario hook
        When I run the tests
        Then BeforeScenario gets called once per scenario outline

    Scenario: Before step hook works correctly
        Given I have a before step hook
        When I run the tests
        Then BeforeStep gets called once per step

    Scenario: After step hook works correctly
        Given I have an after step hook
        When I run the tests
        Then AfterStep gets called once per step

    Scenario: After scenario hook works correctly
        Given I have an after scenario hook
        When I run the tests
        Then AfterScenario gets called once per scenario

    Scenario: Scenario with the same name does not collide
        Given I have a scenario defined
        When I run the tests
        Then The scenario runs without crashing

    Scenario: Scenario with the same name does not collide
        Given I have a scenario defined
            And The steps are slightly different
        When I run the tests
        Then The scenario runs without crashing

    Scenario: Some unimplemented steps
        Given I have some steps that have not been implemented
        When I look in my test report
        Then I see some PENDING steps with a swift attachment
            And I can copy and paste the swift code into my test case

    Scenario: Something that can't be easily tested
        Given I point my step to a unit test
        When I run the tests
        Then The unit test runs

    Scenario: Unimplemented scenario with DocString
        Given a DocString of some kind that is not implemented
        """xml
        <foo>
            <bar />
        </foo>
        """
        When I look in my test report
        Then I see some PENDING steps with a swift attachment
            And I can copy and paste the swift code into my test case
            
    Scenario: Unimplemented scenario with data table
        Given I have some data table that is not implemented
            | tbl |
            | foo |
        When I look in my test report
        Then I see some PENDING steps with a swift attachment
            And I can copy and paste the swift code into my test case
