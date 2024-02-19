<?xml version="1.0" encoding="UTF-8"?>
<Project Version="3" Minor="2" Path="D:/Tasks/RTL_Libraries/trigonometric_function/cos_function/td">
    <Project_Created_Time></Project_Created_Time>
    <TD_Version>5.6.88061</TD_Version>
    <Name>cos_function</Name>
    <HardWare>
        <Family>PH1</Family>
        <Device>PH1A400SFG900</Device>
        <Speed>-2</Speed>
    </HardWare>
    <Source_Files>
        <Verilog>
            <File Path="../cos_function_x1.v">
                <FileInfo>
                    <Attr Name="UsedInSyn" Val="true"/>
                    <Attr Name="UsedInP&R" Val="true"/>
                    <Attr Name="BelongTo" Val="design_1"/>
                    <Attr Name="CompileOrder" Val="1"/>
                </FileInfo>
            </File>
        </Verilog>
    </Source_Files>
    <FileSets>
        <FileSet Name="design_1" Type="DesignFiles">
        </FileSet>
        <FileSet Name="constraint_1" Type="ConstrainFiles">
        </FileSet>
    </FileSets>
    <TOP_MODULE>
        <LABEL></LABEL>
        <MODULE>cos_function_x1</MODULE>
        <CREATEINDEX>user</CREATEINDEX>
    </TOP_MODULE>
    <Property>
    </Property>
    <Device_Settings>
    </Device_Settings>
    <Configurations>
    </Configurations>
    <Runs>
        <Run Name="syn_1" Type="Synthesis" ConstraintSet="constraint_1" Description="" Active="true">
            <Strategy Name="Default_Synthesis_Strategy">
                <DesignProperty>
                    <infer_fsm>auto</infer_fsm>
                </DesignProperty>
                <GlobalProperty>
                    <thread>32</thread>
                </GlobalProperty>
            </Strategy>
            <UserParams>
            </UserParams>
        </Run>
        <Run Name="phy_1" Type="PhysicalDesign" ConstraintSet="constraint_1" Description="" SynRun="syn_1" Active="true">
            <Strategy Name="Default_PhysicalDesign_Strategy">
            </Strategy>
            <UserParams>
            </UserParams>
        </Run>
    </Runs>
    <Project_Settings>
    </Project_Settings>
</Project>
