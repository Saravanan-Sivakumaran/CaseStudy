Open Browser	https://magazine.trivago.com/	gc
Maximise Broswer Window
Click Element	//*[@class="search-icon"]
Wait Until Element is Visible	//input[@class="input search-input"]
Input Text	//input[@class="input search-input"]
Press Keys	None	RETURN
Wait Until Element is Visible	//*[@class="section-title"]
${text}	Get Text	//*[@class="section-title"]
${List}	Split String	${text}
${Value}	Get From List	${List}
${Value}	Convert to Integer	${Value}
log	${Value}
${Element_Count}	Get Element Count	//div[@class="search-suggestions"]//preceding::section/div/div[@class="article-card col col-xs-12 col-sm-6col-md-6"]
Should be Equal	${Element_Count}	${Value}