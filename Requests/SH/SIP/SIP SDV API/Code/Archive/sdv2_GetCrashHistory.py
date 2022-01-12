# ------------------------------------------------------
# SDV 2 Samples python script
# All Crash History API functions
# Author: Ranga  Date: June, 2020
# ------------------------------------------------------
import json
import requests
import os

# -----------------------------------------------------
# USING DEV SERVER, Data might not be up to date
# APIKEY - use default provided for DEV
# -----------------------------------------------------
# _api_url   = "http://dotdevgisiis02/SafetyViewer2/SafetyVwrServicesAPI/Api/"
# _api_hdr   = {'APIKEY': 'SDV2-DEV'};

# -----------------------------------------------------
# USING PRODUCTION SERVER
# APIKEY is required for PRODUCTION
# -----------------------------------------------------
_api_url = "http://dotvgisweb/SafetyViewer2/SafetyVwrServicesAPI/Api/"
_api_hdr = {'APIKEY': '6A0CE5E4-A4FF-4520-A3C9-B3695DCF1FF4'};
_api_proxy = {
    "http": None,
    "https": None
}


# ------------------------------------
# CrashHistory: New Request
# ------------------------------------
def GetCrashHistory():
    _req_id = 0;
    _url = _api_url + "Crash/GetCrashHistory";
    _data = {
        "req_id": 0,
        "sip_id": "",
        "prj_title": "Crash History Sample",
        "sel_type": "SEGMENT",
        "nd_seg_ids": "166005,166006,166007,166008,37451,37455,37457",
        "from": "01/01/2014",
        "to": "12/31/2018",
        "usr_id": "Seth",
        "crashfilters": []
    }
    r = requests.post(_url, data=_data, headers=_api_hdr, proxies=_api_proxy)
    if (r.ok):

        jData = json.loads(r.content)

        print("Output contains {0} properties".format(len(jData)))
        print("\n")
        _req_id = jData["req_id"]
        print("req_id: " + str(jData["req_id"]))
        for row in jData["crash_hist"]:
            for c in row:
                print (c + ":" + str(row[c]))  # + ": " + str(jData["crash_hist"][key]))
            print("------");
    else:
        print("Error\n")
        print(r.reason + ', ' + r.text)

    return _req_id


# --------------------------------------------------------
#  CrashHistory: Get UPDATE of an old Request
# --------------------------------------------------------
def GetCrashHistoryUpdate(req_id):
    _url = _api_url + "Crash/GetCrashHistory";
    _data = {
        "req_id": str(req_id),
        "action": "UPDATE"
    }
    r = requests.post(_url, data=_data, headers=_api_hdr, proxies=_api_proxy)
    if (r.ok):
        jData = json.loads(r.content)
        print("Output contains {0} properties".format(len(jData)))
        print("\n")
        _req_id = jData["req_id"]
    else:
        print("Error\n")
        print(r.reason + ', ' + r.text)

    return _req_id


# ------------------------------------
# Get PDF file, req_id is needed
# ------------------------------------
def GetCrashHistoryPDF(req_id):
    _url = _api_url + "Crash/GetCrashHistoryPDF?req_id=" + str(req_id);
    r = requests.get(_url, headers=_api_hdr, proxies=_api_proxy)
    if (r.ok):

        os.chdir(".")
        pdf_file = os.getcwd() + "\\" + str(req_id) + ".pdf"
        if os.path.exists(pdf_file):
            pdf_file = os.getcwd() + "\\" + str(req_id) + "_2.pdf"
        print("PDF File ", pdf_file)
        f = open(pdf_file, "wb")
        bary = bytearray(r.content)
        f.write(bary)
        f.close()

        # os.system(r'start ' + pdf_file)
        os.startfile(pdf_file)
    else:
        print("Error\n")
        print(r.reason + ', ' + r.text)


# ------------------------------------
# Get Excel file, req_id is needed
# ------------------------------------
def GetCrashHistoryExcel(req_id):
    _url = _api_url + "Crash/GetCrashHistoryExcel?req_id=" + str(req_id) + "&typ=CSV";
    r = requests.get(_url, headers=_api_hdr, proxies=_api_proxy)
    if (r.ok):

        os.chdir(".")
        file = os.getcwd() + "\\" + str(req_id) + ".csv"
        if os.path.exists(file):
            file = os.getcwd() + "\\" + str(req_id) + "_2.csv"
        print("Excel CSV File ", file)
        f = open(file, "wb")
        bary = bytearray(r.content)
        f.write(bary)
        f.close()

        os.startfile(file)
    else:
        print("Error\n")
        print(r.reason + ', ' + r.text)


# ------------------------------------
# Get CrashHistory of a SIP project
# sip_id is needed
# ------------------------------------
def GetSIPCrashHistoryPDF(sip_id, fr, to):
    _url = _api_url + "Crash/GetSIPCrashHistoryPDF?sip_id=" + str(sip_id) + "&from=" + fr + "&to=" + to;
    r = requests.get(_url, headers=_api_hdr, proxies=_api_proxy)
    if (r.ok):

        os.chdir(".")
        file = os.getcwd() + "\\" + str(sip_id) + ".pdf"
        if os.path.exists(file):
            file = os.getcwd() + "\\" + str(sip_id) + "_2.pdf"
        print("PDF File ", file)
        f = open(file, "wb")
        bary = bytearray(r.content)
        f.write(bary)
        f.close()

        os.startfile(file)
    else:
        print("Error\n")
        print(r.reason + ', ' + r.text)


# -------------------
# main program.....
# -------------------
print("#=====================================")
print("# SDV 2 Samples python script")
print("# GetCrashHistory Example")
print("# Gets req_id and retrieves PDF ")
print("# GetCrashHistoryPDF Example")
print("# GetCrashHistoryExcel Example")
print("# GetSIPCrashHistoryPDF Example")
print("#=====================================")

req_id = 0
os.environ['no_proxy'] = _api_url;
print("Executing.... Crash History")
# ------------------------------------
# Get CrashHistory: NEW REQUEST
# ------------------------------------
req_id = GetCrashHistory()
if req_id > 0:
    print("Fetching PDF Export file for Crash History Request ID:" + str(req_id))
    GetCrashHistoryPDF(req_id);
if req_id > 0:
    print("Fetching CSV Export file for Crash History Request ID:" + str(req_id))
    GetCrashHistoryExcel(req_id);

# ------------------------------------
# Get CrashHistory: UPDATE REQUEST
# ------------------------------------
if req_id > 0:
    print("Get updated Crash History for Request ID:" + str(req_id))
    GetCrashHistoryUpdate(req_id);

    print("Fetching PDF Export file for Crash History Request ID:" + str(req_id))
    GetCrashHistoryPDF(req_id);

# print("Getting PDF Export file for Crash History SIP Project ID:866")
# GetSIPCrashHistoryPDF(866)

# -------------------------------------
