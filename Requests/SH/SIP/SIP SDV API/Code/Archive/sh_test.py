import json
import requests
import os

_api_url = "http://dotvgisweb/SafetyViewer2/SafetyVwrServicesAPI/Api/"
_api_hdr = {'APIKEY': '6A0CE5E4-A4FF-4520-A3C9-B3695DCF1FF4'};
_api_proxy = {
    "http": None,
    "https": None
}

_req_id = 0;
_url = _api_url + "Crash/GetCrashHistory";
_data = {
    "req_id": 0,
    "sip_id": "1319",
    "prj_title": "Crash History Sample",
    "sel_type": "NODE",
    "nd_seg_ids": "",
    "from": "01/01/2014",
    "to": "12/31/2018",
    "usr_id": "Seth",
    "crashfilters": []
}

r = requests.post(_url, data=_data, headers=_api_hdr, proxies=_api_proxy)
r.ok

jData = json.loads(r.content)
jData['CrashByAgeGroup'][3]
#####################################################################################
##########################################################################################################################################################################
#####################################################################################
#####################################################################################
#####################################################################################


# Overview - Get a subset of sip project and run them through the safety data viewer and get a subset of what is in the full report.

# 1. Query SIP Portal and grab all projectids from 2019
# 2. Query API for crash history for each 2019 sip project
# 3. From json output of #2 grab Senior Injury Age - (Percent of Known Injuries vs Percent of Known Injuries(Boro))
# 4. Associate Senior Injury data with sip pid
# 5. Write data to excel sheet
# 6. Re-write to make it more generic/reusable



from ris import pysqldb
from IPython.display import Markdown, clear_output
from sqlalchemy import create_engine
import ris
import getpass
import datetime
import pandas as pd
import numpy as np
import os
import requests
import json

timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')

_api_url = "http://dotvgisweb/SafetyViewer2/SafetyVwrServicesAPI/Api/"
_api_hdr = {'APIKEY': '986E90F3-5CDF-460C-B5C3-309E27FDB170'};


def grabSipProjects(year):
    """
    Fucntion to grab SIP crash history
    :param year (int): year of SIP crash history data desired
    """

    db.query("""
            SELECT pid 
            FROM sip_projects
            WHERE sip_year = {yr}
    """.format(yr=year))


def GetSIPCrashHistory(pid):
    """
    Fucntion to grab SIP crash history
    :param pid: SIP project id
    """

    # 1 access the SIP crash history

    _req_id = 0;
    _url = _api_url + "Crash/GetCrashHistory";
    _data = {
        "req_id": 0,
        "sip_id": "%s" % pid,
        "prj_title": "Crash History Sample",
        "sel_type": "NODE",
        "nd_seg_ids": "47444,100531,9031585,9031837",
        "from": "01/01/2014",
        "to": "12/31/2018",
        "usr_id": "Sam",
        "crashfilters": []
    }
    print _data
    r = requests.post(_url, data=_data, headers=_api_hdr)
    print(r.status_code)
    dictionary = json.dumps(r.json(), sort_keys=True, indent=4)
    print(dictionary)


def SIP_Subset(data_table, cross_tab):
    """
    Function to grab subset of data from data table
    :param cross_tab: cross_tab of data desired
    """


# MAIN

GetSIPCrashHistory(1319)