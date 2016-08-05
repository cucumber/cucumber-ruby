Feature: Suites
  In order to use different worlds for executing scenarios,
  suites can be configured to run certain tests in a specifc world.
  Rules:
    - multiple suites can be configured with aggrated the results
  
  Background:
    Given Cucmber is configured with an ios suite and android suite
    
  Scenario: different automation for iOS and Android  
    Given a file named "features/image_sharing.feature" with:
      """
      Feature: Sharing an image

        Scenario: regular sharing
          Given I have taken a picture
          When I share it with my friend
          Then my friend can see the picture    

        @ios-only
        Scenario: automactially add to iCloud
          Given I have taken a picture
          When I share it with my friend
          Then my iCloud album contains the picture
      """
      When I run `cucumber -q`
      Then it should pass with exactly:
        """
        Suite: ios (~@android-only)
        Feature: Sharing an image

          Scenario: regular sharing
            Given I have taken a picture
            When I share it with my friend
            Then my friend can see the picture    

          @ios-only
          Scenario: automactially add to iCloud
            Given I have taken a picture
            When I share it with my friend
            Then my iCloud album contains the picture
        
        Suite: android (~@ios-only)  
        Feature: Sharing an image

          Scenario: regular sharing
            Given I have taken a picture
            When I share it with my friend
            Then my friend can see the picture    

        3 scenarios (3 passed)
        9 steps (9 passed)

        """