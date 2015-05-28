# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

from testtools.matchers import Equals
from autopilot.matchers import Eventually

from webbrowser_app.tests import StartOpenRemotePageTestCaseBase


class TestHistory(StartOpenRemotePageTestCaseBase):

    def test_history_not_save_404(self):
        url = self.base_url + "/404page"
        self.main_window.go_to_url(url)
        self.main_window.wait_until_page_loaded(url)

        # A valid url to be sure the fact the 404 page isn't present in the
        # history view isn't a timing issue.
        url = self.base_url + "/test2"
        self.main_window.go_to_url(url)
        self.main_window.wait_until_page_loaded(url)

        history = self.open_history()
        domain_entries = history.get_domain_entries()
        # 1 domain: the local one
        self.assertThat(lambda: len(history.get_domain_entries()),
                        Eventually(Equals(1)))

        self.pointing_device.click_object(domain_entries[0])
        expanded_history = history.get_expanded_view()

        # 2 addresses: /test1 and /test2
        self.assertThat(lambda: len(expanded_history
                                    .select_many("UrlDelegate",
                                                 objectName="entriesDelegate")
                                    ),
                        Eventually(Equals(2)))

        delegates = expanded_history.select_many("UrlDelegate",
                                                 objectName="entriesDelegate")

        self.assertThat(sorted([delegate.url for delegate in delegates]),
                        Equals(sorted([self.url, url])))
