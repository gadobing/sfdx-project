({
    doInit : function(component, event, helper) {
      
    },
    refresh: function(component, event, helper){
        console.log('Reached');

        $A.get('e.force:refreshView').fire();
        let reloadPage = event.getParam('reloadEventDetail');
            if(reloadPage){
                let workspaceAPI = component.find("myworkspace")
                workspaceAPI.getFocusedTabInfo().then(function(response){
                    let focusedTabId = response.tabId;
                    workspaceAPI.refreshTab({
                        tabId: focusedTabId,
                        includeAllSubtabs: true
                    });
                    $A.get("e.force:closeQuickAction").fire();
                })
                .catch(function(error){
                    console.log(error);
                  
                })
            }
    },
})