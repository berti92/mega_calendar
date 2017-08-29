[![Paypal Donate](https://img.shields.io/badge/Paypal-donate-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=simplyanamedude@gmail.com&lc=GB&item_name=Andreas%20Treubert&no_note=0&currency_code=EUR&bn=PP-DonationsBF:btn_donate_LG.gif:NonHostedGuest)
[![Twitter Follow](https://img.shields.io/badge/follow-twitter-blue.svg)](https://twitter.com/AppDevbert)
[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&maxAge=2592000?style=flat-square)](https://twitter.com/intent/tweet?button_hashtag=MegaCalendar)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/1e9f23bef62d487bb634bd26f05a7d7e)](https://www.codacy.com/app/simplyanamedude/mega_calendar?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=berti92/mega_calendar&amp;utm_campaign=Badge_Grade)

<h1>mega_calendar</h1>

Plugin for redmine: Brings a better calendar and more oppurtunities to set holidays.<br/>
Only compatible/tested with redmine 3.0.X, 3.1.X, 3.2.X, 3.3.X and Ruby 2.2, Rails 4.2<br/>
Please test this plugin for other redmine versions and let me know if there are any bugs.<br/>

<h2>Installation</h2>

Standard redmine plugin installation: You can read the generic plugin installation guide <a href="http://www.redmine.org/projects/redmine/wiki/Plugins" target="_blank">here</a> or you can use the following guide (Debian 7, Apache2/Passenger).

Go to your redmine plugins-folder<br>
<code>cd /srv/redmine/plugins</code><br>
Download the latest plugin-Version:<br>
<code>wget https://github.com/berti92/mega_calendar/archive/master.zip</code><br>
Unzip the downloaded zip-File<br>
<code>unzip master.zip</code><br>
Rename the folder:<br>
<code>mv mega_calendar-master mega_calendar</code><br>
Give the folder the right privileges in this case apache (to execute the command you must be root)<br>
<code>chown -R www-data.www-data mega_calendar</code><br>
Go to the plugin folder<br>
<code>cd /srv/redmine/plugins/mega_calendar</code><br>
Install the gems<br>
<code>bundle</code><br>
Go back to your redmine folder<br>
<code>cd /srv/redmine</code><br>
Migrate the database<br>
<code>bundle exec rake redmine:plugins:migrate RAILS_ENV=production</code><br>
Now restart your redmine and you can configure the plugin in the admin settings in redmine.<br>
To start redmine under apache2/passenger, please execute the following commands <br>
<code>cd /srv/redmine</code><br>
<code>touch tmp/restart.txt</code>

If you got installation problems, then please have a look at the [wiki](https://github.com/berti92/mega_calendar/wiki/FAQ).

<h2>Usage</h2>

Within a issue you are able to set a time as start and end, to get a better calendar view. On top of the page you can reach the calendar and holiday section.

Please make sure that you set your users, that will be allowed to use this plugin and that the sub-path is set to "/" without quotes at the plugin settings.

<h2>Screenshots</h2>

A quick overview about this plugin, you'll get on <a href="http://www.devbert.de/index.php/en/project/megacalendar/">http://www.devbert.de/index.php/en/project/megacalendar/</a>

<h2>Newsletter</h2>

If you want to stay up to date, you can subscribe to the MegaCalendar newsletter <a href="https://devbert.us15.list-manage.com/subscribe?u=ce1f4237d49c936e451ef9e82&id=7fa4fd4275">here</a>.

<h2>History</h2>

1.7.0: Added support for redmine 3.4.X

1.6.0: Added possibilty to show issues with empty dates. Added possibility to save/edit and delete filters within the calendar. Added possibilty to create global holidays.<br> Please make sure that you migrate your database.<br>
<code>cd /srv/redmine</code><br>
<code>bundle exec rake redmine:plugins:migrate RAILS_ENV=production</code>

1.5.0: Added filters. Added functionality to include users to the calendar within the plugin settings. Mobile optimization 

1.4.0: Added export functionality (ics) - Please make sure, that you have installed the gems -> <a href="https://github.com/berti92/mega_calendar/wiki/Installation">WIKI</a>

1.3.8: Now you are able to set the start of the week within the plugin settings

1.3.7: Bugfix

1.3.6: Bugfix

1.3.5: Bugfix

1.3.4: Added ability to create issues from the calendar, just click on a free space on the calendar

1.3.3: Added support for Redmine 3.3.X

1.3.2: Added support for Redmine 3.2.X

1.3.1: Bugfix

1.3.0: Added right for this plugin

1.2.0: Added support for sub paths

1.1.0: Fixed a few bugs, added widget to MyPage

1.0.0: First release

<h2>You like my work?</h2>

If you like my work, you can buy me a coffee [![Paypal Donate](https://img.shields.io/badge/Paypal-donate-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=simplyanamedude@gmail.com&lc=GB&item_name=Andreas%20Treubert&no_note=0&currency_code=EUR&bn=PP-DonationsBF:btn_donate_LG.gif:NonHostedGuest) or try my new browser game:
<a href="http://sketcharama.com/">Sketcharama</a> 

If you need customized software, you can contact me <a href="mailto:support@devbert.de">support@devbert.de</a> or visit my company website <a href="http://www.devbert.de">www.devbert.de</a>.

<h2>License</h2>

MIT License
