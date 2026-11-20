<?xml version="1.0" encoding="ISO-8859-1"?>
<npc name="Nome" floorchange="0" walkinterval="4000">
        <health now="150" max="150"/>
        <look type="133" head="20" body="120" legs="75" feet="13"/>

        <interaction range="3" idletime="30">

                <interact keywords="hi" focus="1">
                        <keywords>hello</keywords>

                        <response>
                                <action name="script">
                                <![CDATA[
                                selfSay("Welcome " .. getCreatureName(cid) .. ".", cid)
                                ]]>
                                </action>
                        </response>

                </interact>

                <interact keywords="bye" focus="0">
                        <keywords>farewell</keywords>
                        <response text="Good bye.">
                        </response>
                </interact>
        
                <interact keywords="secret" storageId="1031" storageValue="1" storageComp="less">
                        <response>
                                <action name="script">
                                <![CDATA[
                                selfSay("Quer abrir a porta por 200k ?", cid)
                                ]]>
                                </action>
                                <interact keywords="yes">
                                        <response>
                                                <action name="script">
                                                <![CDATA[
                                                if doPlayerRemoveMoney(cid, 200000) then
                                                    selfSay("Você ja pode passar por ela.", cid)
                                                    doPlayerSetStorageValue(cid, 1031, 1)
                                                else
                                                    selfSay("Você não possui gp's suficientes.", cid)
                                                end
                                                ]]>
                                                </action>
                                        </response>
                                </interact>
                        </response>
                </interact>
                
                <interact keywords="secret" storageId="1031" storageValue="1" storageComp="equal">
                        <response>
                                <action name="script">
                                <![CDATA[
                                selfSay("Você ja pode passar pela porta.", cid)
                                ]]>
                                </action>
                        </response>
                </interact>
        
        </interaction>

</npc>