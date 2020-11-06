-- Fitsum 
-- IM for Shure MAX10
-- Date 

-- Online Offline Status
if Device.Offline then
    -- NamedControl.SetValue("COLed",0)
    NamedControl.SetPosition("COLed", 1)
else
    NamedControl.SetPosition("COLed",0)
end

--Helper functions
function parseLine(rxLine)
    meterChannel, meterLevel = string.match(rxLine, "< REP (%d) AUDIO_IN_PEAK_LVL (%d%d%d) ")
    if(meterChannel ~= nil and meterLevel ~= nil) then
    end
    deviceMuteStatus = string.match(rxLine, "< REP DEVICE_AUDIO_MUTE (%a+) ")
    if(deviceMuteStatus ~= nil)then
        -- print(deviceMuteStatus)
    end

    polarChannel,pollarMode = string.match(rxLine, "< REP (%d) POLAR_PATTERN (%a+) ")
    if(polarChannel ~= nil and pollarMode ~= nil )then
        -- print(polarChannel .. pollarMode)
    end
end
-- TCP creation
MyTCP = TcpSocket.New()
MyTCP:Connect(NamedControl.GetText('EnterIP'), 2202)
print(NamedControl.GetText('EnterIP'))

--TCP Data Handler
MyTCP.EventHandler = function(sock, evt, err)
	if evt == TcpSocket.Events.Connected then
        print("socket connected\r")
        NamedControl.SetText("ConnectedStatus0", "Connected")
	elseif evt == TcpSocket.Events.Reconnect then
        print("socket reconnecting...\r")   
	elseif evt == TcpSocket.Events.Data then
        repeat
            rxLine = MyTCP:ReadLine(TcpSocket.EOL.Custom,">")
            if (nil ~= rxLine) then
                -- print(rxLine)
                parseLine(rxLine)
            end
        until nil == rxLine
	elseif evt == TcpSocket.Events.Closed then
		print("socket closed by remote\r")
	elseif evt == TcpSocket.Events.Error then
        print(string.format("Error: '%s'\r", err))
        NamedControl.SetText("ConnectedStatus0", "Not Connected")
	elseif evt == TcpSocket.Events.Timeout then
		print("socket closed due to timeout\r") 
	else
		print("unknown socket event\r")
	end
end
-----Mute_States
is1Muted = false
is2Muted = false
is3Muted = false
is4Muted = false
is5Muted = false
isAutomixuted6 = false
print(TcpSocket.Events.Connected)

------------------------------------------------TimerClick Function
function TimerClick ()
-- Mute Individual channels-
muteCh1 = NamedControl.GetValue("MuteCha1")
if muteCh1 == 1.0 then
    if is1Muted == false then
        MyTCP:Write("< SET 1 AUDIO_MUTE ON >")
        is1Muted = true
    end        
else
    MyTCP:Write("< SET 1 AUDIO_MUTE OFF >")
    is1Muted = false
end
MuteCha2 = NamedControl.GetValue("MuteCha2x")
if MuteCha2 == 1.0 then
    if is2Muted == false then
        MyTCP:Write("< SET 2 AUDIO_MUTE ON >")
        is2Muted = true
    end        
else
    MyTCP:Write("< SET 2 AUDIO_MUTE OFF >")
    is2Muted = false
end
muteCh3 = NamedControl.GetValue("MuteCha3")
if muteCh3 == 1.0 then
    if is3Muted == false then
        MyTCP:Write("< SET 3 AUDIO_MUTE ON >")
        is3Muted = true
    end        
else
    MyTCP:Write("< SET 3 AUDIO_MUTE OFF >")
    is3Muted = false
end
muteCh4 = NamedControl.GetValue("MuteCha4")
if muteCh4 == 1.0 then
    if is4Muted == false then
        MyTCP:Write("< SET 4 AUDIO_MUTE ON >")
        is4Muted = true
    end        
else
    MyTCP:Write("< SET 4 AUDIO_MUTE OFF >")
    is4Muted = false
end  
muteAutomix = NamedControl.GetValue("muteAutomix")
if muteAutomix == 1.0 then
    if isAutomixuted == false then
        MyTCP:Write("< SET 5 AUDIO_MUTE ON >")
        isAutomixuted = true
    end        
else
    MyTCP:Write("< SET 5 AUDIO_MUTE OFF >")
    isAutomixuted = false
end 
    for i = 1,4,1 do
        UpdatePolarPattern(i)
    end        
    --UpdateChannelAngle
    for i = 1,4,1 do
        UpdateChannelAngle(i)
    end
    -- UpdateFader 
    for i = 1,5,1
    do
        updateFader(i) 
    end--UpdateChannelAngle

end-- timer Function ends here

function UpdatePolarPattern(pValue)
    PolarValue = NamedControl.GetValue("PolarPatternCh"..pValue)
    if(PolarValue == 0.0) then
        MyTCP:Write("< SET "..pValue.." POLAR_PATTERN TOROID >")
    elseif(PolarValue == 1.0)then
        MyTCP:Write("< SET "..pValue.." POLAR_PATTERN OMNI >")
    elseif(PolarValue == 2.0)then
        MyTCP:Write("< SET "..pValue.." POLAR_PATTERN CARDIOID >")
    elseif(PolarValue == 3.0)then
        MyTCP:Write("< SET "..pValue.." POLAR_PATTERN SUPER >")
    elseif(PolarValue == 4.0)then
        MyTCP:Write("< SET "..pValue.." POLAR_PATTERN HYPER >")
    elseif(PolarValue == 5.0)then
        MyTCP:Write("< SET "..pValue.." POLAR_PATTERN BIDIRECTION >")
    end  
end--UpdatePolarPattern
function UpdateChannelAngle(pattern)
    ChanelAngle = math.floor(NamedControl.GetValue("numAngle"..pattern))
    if (ChanelAngle == 0)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 0 >")
    elseif(ChanelAngle == 15)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 15 >")
    elseif(ChanelAngle == 30)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 30 >")
    elseif(ChanelAngle == 45)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 45 >")
    elseif(ChanelAngle == 60)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 60 >")
    elseif(ChanelAngle == 75)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 75 >")
    elseif(ChanelAngle == 90)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 90 >")
    elseif(ChanelAngle == 105)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 105 >")
    elseif(ChanelAngle == 120)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 120 >")
    elseif(ChanelAngle == 135)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 135 >")
    elseif(ChanelAngle == 150)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 150 >")    
    elseif(ChanelAngle == 165)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 165 >")    
    elseif(ChanelAngle == 180)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 180 >")    
    elseif(ChanelAngle == 195)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 195 >")    
    elseif(ChanelAngle == 210)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 210 >")    
    elseif(ChanelAngle == 225)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 225 >")    
    elseif(ChanelAngle == 240)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 240 >")    
    elseif(ChanelAngle == 255)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 255 >")    
    elseif(ChanelAngle == 270)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 270 >")    
    elseif(ChanelAngle == 285)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 285 >")
    elseif(ChanelAngle == 300)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 300 >")    
    elseif(ChanelAngle == 315)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 315 >")    
    elseif(ChanelAngle == 330)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 330 >")    
    elseif(ChanelAngle == 345)then
        MyTCP:Write("< SET "..pattern.." LOBE_ANGLE 345 >")        
    end
end--UpdatePolarPattern
function updateFader(whichFader)
   fadervalue = math.floor(NamedControl.GetValue("NumericCha" .. whichFader))
    if (fadervalue == -80)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 0000 >" )
    elseif(fadervalue == -70)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 0400 >" )
    elseif(fadervalue == -60)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 0500 >" )
    elseif(fadervalue == -50)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 0600 >" )
    elseif(fadervalue== -40)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 0700 >" )
    elseif(fadervalue == -30 )then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 0800 >" )
    elseif(fadervalue == -20)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 0900 >" )
    elseif(fadervalue == -10 )then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 1000 >" )
    elseif(fadervalue == 0 )then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 1100 >" )
    elseif(fadervalue == 10 )then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 1200 >" )
    elseif(fadervalue == 20)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 1300 >" )
    elseif(fadervalue > 25 or fader1Value == 30)then
        MyTCP:Write("< SET "..whichFader.." AUDIO_GAIN_HI_RES ".." 1400 >" )
    end
    
    -- print("< SET " .. whichFader .. " AUDIO_GAIN_HI_RES " .. math.floor(NamedControl.GetValue("NumericCha" .. whichFader))*14)
end--UpdateFaderEndsHere
function UpdateUI()
    RebootDevice = math.floor(NamedControl.GetValue("RebootDevice")) 
    if(RebootDevice == 1)then
        MyTCP:Write("< SET REBOOT >")
    end

    ConnectionStatus = MyTCP.IsConnected
    Connect = NamedControl.GetValue("ConnectDevice")
    if(Connect == 1.0)then
        if(ConnectionStatus == false)then
            connectTCP()
        end
    end

    FlashDSPValue = NamedControl.GetValue("FlashDSP")
        if FlashDSPValue == 1 then
            MyTCP:Write("< SET FLASH ON >")
            print("Unit Flashed")
        else
           --TODO
        end
end
function connectTCP()
    MyTCP = TcpSocket.New()
    MyTCP:Connect(NamedControl.GetText('EnterIP'), 2202)
	if(MyTCP.IsConnected) then
		print("Socket is connected")
	else
		print("TCP failed to connect")
	end
end


--Timer 
MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(2.7)

MyTimer2 = Timer.New()
MyTimer2.EventHandler = UpdateUI
MyTimer2:Start(.25)




