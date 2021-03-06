﻿import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import pimaxvr.PiService 1.0

MyDialog2{
    id:dialog
    property int status: 0;
    property int wait: 0;
    property int progress: 0;
    property bool connect: piService.connect;
    property bool modeType: piService.modeType;
    onVisibleChanged: {
        if(visible){
            wait = 0;
            status = 0;
            progress = 0;
            waitTimer.start();
        }
    }
    onConnectChanged: {
        wait++;
        console.log("ModeSwitchWait connect",connect,wait);
    }
    onModeTypeChanged: {
        console.log("ModeSwitchWait onModeTypeChanged",modeType);
        status = 1;
        waitTimer.stop();
        progress = 100;
    }

    Timer{
        id:waitTimer;
        interval: 500;
        repeat: true;
        triggeredOnStart: true;
        onTriggered: {
            progress++;
            if(progress>100){//50s超时
                waitTimer.stop();
                status = 2;
            }else if(progress>50){
                piService.getModeType();
            }
        }
    }
    clientWidth: 700;
    clientHeight: 370;
    title:qsTr("模式切换")
    Rectangle{
        parent: clientArea;
        width:parent.width;height: parent.height;
        color:translucent

        Rectangle{
            id:progressBar
            height: 30;
            width: parent.width*3/4;
            anchors.centerIn: parent;
            color:gray;
            Rectangle{
                height: parent.height;
                width: parent.width*(progress>100?100:progress)/100;
                color: blue
            }
        }

        MyLabel{
            id:labelDownloading;
            text:{
                if(status==0){
                    return qsTr("正在模式切换，请稍候...");
                }else if(status==1){
                    return qsTr("模式切换完成");
                }else{
                    return qsTr("模式切换失败")
                }
            }
            font.pixelSize: 18
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.bottom: progressBar.top;anchors.bottomMargin: 50;
        }

        TextButton{
            id:btnOK;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: progressBar.bottom;anchors.topMargin: 40;
            text:qsTr("确 定")
            width: 130;height: 30;
            mouseArea.onClicked: {
                waitTimer.stop();
                dialog.close();
                if(status==1){
                    piService.switchScreenOrient();
                }
                piService.switchingMode = false;
            }
            visible: status>0;
        }
    }
}
