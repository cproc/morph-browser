/*
 * Copyright 2013-2014 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import webcontainer.private 0.1

Page {
    id: root

    property string providerId: ""
    property string applicationId: ""
    property int selectedAccount: -1

    signal accountSelected(var credentialsId)
    signal done(bool successful)

    property string __applicationName: applicationId
    property url __applicationIcon
    property string __providerName: providerId

    visible: true
    anchors.fill: parent

    AccountsLoginPage {
        id: accountsLogin

        anchors.fill: parent
        applicationId: root.applicationId
        providerId: root.providerId

        onAccountSelected: {
            if (credentialsId === -1) {
                showSplashScreen()
            } else {
                accountsPage.selectedAccount = credentialsId
            }
        }
        onDone: accountsPage.done(successful)
    }

    SplashScreen {
        id: splashScreen

        providerName: root.__providerName
        applicationName: root.__applicationName
        iconSource: root.__applicationIcon
        visible: false

        onChooseAccount: PopupUtils.open(accountChooserComponent)
    }

    Component {
        id: accountChooserComponent
        AccountChooserDialog {
            providerId: root.providerId
            applicationId: root.applicationId
        }
    }

    ApplicationModel {
        id: applicationModel
    }

    ProviderModel {
        id: providerModel
        applicationId: root.applicationId
    }

    function __setupApplicationData() {
        for (var i = 0; i < applicationModel.count; i++) {
            if (applicationModel.get(i, "applicationId") === root.applicationId) {
                root.__applicationName = applicationModel.get(i, "displayName")
                root.__applicationIcon = applicationModel.get(i, "iconName")
                break
            }
        }
    }

    function __setupProviderData() {
        for (var i = 0; i < providerModel.count; i++) {
            if (providerModel.get(i, "providerId") === root.providerId) {
                root.__providerName = providerModel.get(i, "displayName")
                break
            }
        }
    }

    Component.onCompleted: {
        __setupApplicationData()
        __setupProviderData()
    }

    function login(forceCookieRefresh) {
        accountsLogin.login(forceCookieRefresh)
    }

    function showSplashScreen() {
        splashScreen.visible = true
    }
}
