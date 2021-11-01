*** Settings ***
Test Setup        Login
Test Teardown     Close Browser
Library           String
Library           SeleniumLibrary
Library           RequestsLibrary
Library           Collections

*** Variables ***
${trivago_magazine_url}    https://magazine.trivago.com/

*** Test Cases ***
1_Verify search results
    Search Hotels With Location    Texas

2_Verify featured hotels
    Search Hotels With Location    Texas
    Check all featured hotels are present in article    Mom Knows Best: Family Vacations in Texas
    Check broken links

*** Keywords ***
Login
    Open Browser    ${trivago_magazine_url}    gc
    Maximize Browser Window

Check broken links
    #[Arguments]    ${trivago_magazine_url}
    #Go to    https://magazine.trivago.com/midwest-family-vacations/
    ${element_list}=    Get Webelements    xpath=//a[@href]
    ${href_list}=    Evaluate    [item.get_attribute('href') for item in $element_list]
    log    ${href_list}
    Create Session    TrivagoMagazine    ${trivago_magazine_url}
    FOR    ${each_href}    IN    @{href_list}
        ${uri}    Remove String    ${each_href}    ${trivago_magazine_url}
        ${has trivago url}=    Evaluate    "${trivago_magazine_url}"in "${each_href}"
        ${response}=    Run Keyword If    ${has trivago url}    Get on Session    TrivagoMagazine    ${uri}
        Run Keyword If    ${has trivago url}    Should Be Equal as Strings    ${response.status_code}    200
    END

Search Hotels With Location
    [Arguments]    ${Search_Text}
    Click Element    //*[@class="search-icon"]
    Wait Until Element is Visible    //input[@class="input search-input"]
    Input Text    //input[@class="input search-input"]    ${Search_Text}
    Press Keys    None    RETURN
    Wait Until Element is Visible    //*[@class="section-title"]
    ${text}    Get Text    //*[@class="section-title"]
    ${List}    Split String    ${text}
    ${Value}    Get From List    ${List}    0
    ${Value}    Convert to Integer    ${Value}
    log    ${Value}
    ${Element_Count}    Get Element Count    //div[@class="search-suggestions"]//preceding::section/div/div[@class="article-card col col-xs-12 col-sm-6 col-md-6"]
    Should be Equal    ${Element_Count}    ${Value}

Check All Featured Hotels Are Present in Article
    [Arguments]    ${Selection}
    Wait Until Element Is Visible    //*[text()="${Selection}"]//following::div[@class="article-card col col-xs-12 col-sm-6 col-md-6"]
    Run Keyword and Ignore Error    Scroll Element Into View    //*[text()="${Selection}"]//following::div[@class="article-card col col-xs-12 col-sm-6 col-md-6"]
    Click Element    //*[text()="${Selection}"]
    Wait Until Keyword Succeeds    20s    2s    Click Element    //*[@class = 'close-pop']
    ${Featured_Hotels}    Get Element Count    //*[@class="hotel-name-list"]
    FOR    ${fh}    IN RANGE    0    ${Featured_Hotels}
        ${hotel_name_full}    Execute Javascript    return document.getElementsByClassName('hotel-name-list')[${fh}].textContent
        ${hotel_name}    SplitString    ${hotel_name_full}    ...
        ${hotel_name}    Get From List    ${hotel_name}    0
        Wait Until Keyword Succeeds    20s    2s    Scroll Element Into View    //*[@class = "trivago-magazine-footer"]
        Element Should be Visible    //span[contains(text(),"${hotel_name}")]
    END
