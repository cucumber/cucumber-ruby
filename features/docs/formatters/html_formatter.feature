Feature: HTML output formatter

  Background:
    Given the standard step definitions
    And a file named "features/scenario_outline_with_undefined_steps.feature" with:
      """
      Feature:

        Scenario Outline:
          Given this step is undefined

        Examples:
          |foo|
          |bar|
      """
    And a file named "features/scenario_outline_with_pending_step.feature" with:
      """
      Feature: Outline

        Scenario Outline: Will it blend?
          Given this step is pending
          And other step
          When I do something with <example>
          Then I should see something
          Examples:
            | example |
            | one     |
            | two     |
            | three   |
      """
    And a file named "features/failing_background_step.feature" with:
      """
      Feature: Feature with failing background step

        Background:
          Given this step fails

        Scenario:
          When I do something
          Then I should see something
      """

  Scenario: an scenario outline, one undefined step, one random example, expand flag on
    When I run `cucumber features/scenario_outline_with_undefined_steps.feature --format html --expand `
    Then it should pass

  Scenario Outline: an scenario outline, one pending step
    When I run `cucumber <file> --format html <flag>`
    Then it should pass
    And the output should contain:
    """
    makeYellow('scenario_1')
    """
    And the output should not contain:
    """
    makeRed('scenario_1')
    """

    Examples:
      | file                                                   | flag     |
      | features/scenario_outline_with_pending_step.feature    | --expand |
      | features/scenario_outline_with_pending_step.feature    |          |

    Examples:
      | file                                                   | flag     |
      | features/scenario_outline_with_undefined_steps.feature | --expand |
      | features/scenario_outline_with_undefined_steps.feature |          |

  Scenario: when using a profile the html shouldn't include 'Using the default profile...'
    And a file named "cucumber.yml" with:
    """
      default: -r features
    """
    When I run `cucumber features/scenario_outline_with_undefined_steps.feature --profile default --format html`
    Then it should pass
    And the output should not contain:
    """
    Using the default profile...
    """

  Scenario: a feature with a failing background step
    When I run `cucumber features/failing_background_step.feature --format html`
    Then the output should not contain:
    """
    makeRed('scenario_0')
    """
    And the output should contain:
    """
    makeRed('background_0')
    """

  Scenario: embedding a screenshot
    Given a file named "features/embed.feature" with:
      """
      Feature: Embed

        Scenario: a screenshot
          Given a step that is embedding a screenshot
      """
    And a file named "features/step_definitions/embed_steps.rb" with:
      """
      Given /^a step that is embedding a screenshot$/ do
        embed 'screenshot.png', 'image/png'
      end
      """
    When I run `cucumber features/embed.feature --format html`
    Then the output should contain:
    """
    <span class="embed"><a href="" onclick="img=document.getElementById('img_0'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false">Screenshot</a><br /><img id="img_0" style="display: none" src="data:image/png;base64,screenshot.png" /></span>
    """

  Scenario: embedding a screenshot via AfterStep hook
    Given a file named "features/embed.feature" with:
      """
      Feature: Embed

        Scenario: a screenshot
          Given a step that is embedding a screenshot
      """
    And a file named "features/step_definitions/embed_steps.rb" with:
      """
      Given /^a step that is embedding a screenshot$/ do
        # Mkay
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      AfterStep do
        embed 'screenshot.png', 'image/png'
      end
      """
      When I run `cucumber features/embed.feature --format html`
    Then the output should contain:
    """
    <ol><li id='' class='step passed'><div class="step_name"><span class="keyword">Given </span><span class="step val">a step that is embedding a screenshot</span></div><div class="step_file"><span>features/step_definitions/embed_steps.rb:1</span></div></li> <script type="text/javascript">moveProgressBar('100.0');</script><span class="embed"><a href="" onclick="img=document.getElementById('img_0'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false">Screenshot</a><br /><img id="img_0" style="display: none" src="data:image/png;base64,screenshot.png" /></span></ol>
    """

  Scenario: embedding a screenshot into Scenario Outline via AfterStep hook
    Given a file named "features/embed.feature" with:
      """
      Feature: Embed

        Scenario Outline: a screenshot
          Given a step that is embedding a <thing>

          Examples:
            | thing |
            | screenshot |
      """
    And a file named "features/step_definitions/embed_steps.rb" with:
      """
      Given /^a step that is embedding a screenshot$/ do
        # Mkay
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      AfterStep do
        embed 'screenshot.png', 'image/png'
      end
      """
    When I run `cucumber features/embed.feature --format html`
    Then the output should contain:
    """
    <tr class='step' id='features_embed_feature_8'><td id="features_embed_feature_8_0" class="step passed"><div><span class="step param">screenshot</span></div></td></tr><tr><td><a href="" onclick="img=document.getElementById('img_0'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false">Screenshot</a><br /><img id="img_0" style="display: none" src="data:image/png;base64,screenshot.png" /></td></tr>
    """
