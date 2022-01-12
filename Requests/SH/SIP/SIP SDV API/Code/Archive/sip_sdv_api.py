
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

Markdown('<strong>Notebook run on: {} | by {} | Using ris library version: {} | File Location: {}'.format(
    timestamp, getpass.getuser(), ris.__version__, os.getcwd()
))


try: 
    db.params['user']
except:
    db = pysqldb.DbConnect(type='PG', server='dotpgsql01', database='sip')



_api_url = "http://dotvgisweb/SafetyViewer2/SafetyVwrServicesAPI/Api/"
_api_hdr = {'APIKEY': '986E90F3-5CDF-460C-B5C3-309E27FDB170'};


"""
#sip = pysqldb.DbConnect(server='dotpgsql01', database='sip', type='PG', user = db.params['user'], password = db.params['password'])
#forms = pysqldb.DbConnect(server='dot55sql01', database='forms', type='MS', user = 'arcgis', password = 'arcgis')

db.connect()

sip_projects = db.dfquery(   SELECT *
                                FROM sip_projects
                                WHERE sip_year = 2019)


def GetAdvCrashHistory():
    _req_id = 0;
    _url = _api_url + "AdvQuery/GetAdvCrashHistory";
    _data = {
        "req_id":0,
        "sip_id ": "866",
        "prj_title": "Advanced Query for SIP Project 866",
        "sel_type": "NODE",
        "nd_seg_ids": "18976",
        "from": "01/01/2010",
        "to": "12/31/2018",
        "usr_id": "Seth",
        "crash_type": "",
        "severity":"",
        "src": "NYS"
    }
    r = requests.post(_url, data=_data, headers=_api_hdr)
    if(r.ok):

        jData = json.loads(r.content)
        print("Output contains {0} properties".format(len(jData)))
        print("\n")
        _req_id = jData["req_id"]
        print("req_id: " + str(jData["req_id"]))
    else:
        print("Error: " + r.reason + ', ' + r.text)

    return _req_id
#--------------------------------------------------
# AdvCrashHistory: Get UPDATE of an old Request
#--------------------------------------------------
def GetAdvCrashHistoryUpdate(req_id):
    _url = _api_url + "AdvQuery/GetAdvCrashHistory";
    _data = {
            "req_id": str(req_id),
            "action": "UPDATE"
        }
    r = requests.post(_url, data=_data, headers=_api_hdr)
    if(r.ok):
        jData = json.loads(r.content)
        print("Output contains {0} properties".format(len(jData)))
        print("\n")
        _req_id = jData["req_id"]
    else:
        print("Error\n")
        print(r.reason + ', ' + r.text)

    return _req_id
#------------------------------------
# Get Excel file, req_id is needed
#------------------------------------
def GetAdvCrashHistoryExcel(req_id):
    _url = _api_url + "AdvQuery/GetAdvCrashHistoryExcel?req_id=" + str(req_id) + "&typ=CSV";
    r = requests.get(_url, headers=_api_hdr)
    if(r.ok):

        os.chdir(".")
        file = os.getcwd() + "\\" +  str(req_id) + ".csv"
        print("Excel CSV File " , file)
        f = open(file, "wb")
        bary = bytearray(r.content)
        f.write(bary)
        f.close()
        os.system(r'start ' + file)
    else:
        print("Error: " + r.reason + ', ' + r.text)




#-------------------
# main program.....
#-------------------
print("#==========================================")
print("# SDV2 Advanced Query Sample python script")
print("# Exec GetAdvCrashHistory, get req_id ")
print("# Use the req_id to get the EXCEL output ")
print("#==========================================")
req_id = 0
print("Executing.... Advanced Query Crash History")
#-----------------------------------------
# Get Advanced CrashHistory: NEW REQUEST
#-----------------------------------------
req_id = GetAdvCrashHistory()
if req_id > 0:
    print("Fetching CSV Export file for Advanced Crash History Request ID:" + str(req_id))
    GetAdvCrashHistoryExcel(req_id);
#------------------------------------------
# Get Advanced CrashHistory: UPDATE REQUEST
#------------------------------------------
if req_id > 0:
    print("Get updated Advanced Crash History for Request ID:" + str(req_id))
    GetAdvCrashHistoryUpdate(req_id);
    print("Fetching CSV Export file for Advanced Crash History Request ID:" + str(req_id))
    GetAdvCrashHistoryExcel(req_id);
print("Completed...")
"""





def GetCrashHistory():	
	_req_id = 0;
	_url = _api_url + "Crash/GetCrashHistory";
	_data = {
            "req_id":0,
            "sip_id": "866",
            "prj_title": "Crash History Sample",
            "sel_type": "NODE",
            "nd_seg_ids": "18976",
            "from": "01/01/2013",
            "to": "12/31/2017",
            "usr_id": "Seth",
            "crashfilters": []
        }
	r = requests.post(_url, data=_data, headers=_api_hdr)
	if(r.ok):
		
		jData = json.loads(r.content)
		print("Output contains {0} properties".format(len(jData)))
		print("\n")
		_req_id = jData["req_id"]
		print("req_id: " + str(jData["req_id"]))
		for row in jData["crash_hist"]:
			for c in row:
				print (c + ":"  + str(row[c])) # + ": " + str(jData["crash_hist"][key]))
			print("------");
	else:
		print("Error\n")	
		print(r.reason + ', ' + r.text)
        
	return _req_id
 
#--------------------------------------------------------
#  CrashHistory: Get UPDATE of an old Request
#--------------------------------------------------------
def GetCrashHistoryUpdate(req_id):	
	_url = _api_url + "Crash/GetCrashHistory";
	_data = {
            "req_id": str(req_id),
			"action": "UPDATE"
        }
	r = requests.post(_url, data=_data, headers=_api_hdr)
	if(r.ok):
		jData = json.loads(r.content)
		print("Output contains {0} properties".format(len(jData)))
		print("\n")
		_req_id = jData["req_id"]
	else:
		print("Error\n")	
		print(r.reason + ', ' + r.text)
	return _req_id
 
#------------------------------------
# Get PDF file, req_id is needed
#------------------------------------
def GetCrashHistoryPDF(req_id):	
	_url = _api_url + "Crash/GetCrashHistoryPDF?req_id=" + str(req_id);
	r = requests.get(_url, headers=_api_hdr)
	if(r.ok):
		
		os.chdir(".")
		pdf_file = os.getcwd() + "\\" +  str(req_id) + ".pdf"
		print("PDF File " , pdf_file)
		f = open(pdf_file, "wb")
		bary = bytearray(r.content)
		f.write(bary)
		f.close()
		os.system(r'start ' + pdf_file)
	else:
		print("Error\n")	
 
#------------------------------------
# Get Excel file, req_id is needed
#------------------------------------
def GetCrashHistoryExcel(req_id):	
	_url = _api_url + "Crash/GetCrashHistoryExcel?req_id=" + str(req_id) + "&typ=CSV";
	r = requests.get(_url, headers=_api_hdr) 
	if(r.ok):
		
		os.chdir(".")
		file = os.getcwd() + "\\" +  str(req_id) + ".csv"
		print("Excel CSV File " , file)
		f = open(file, "wb")
		bary = bytearray(r.content)
		f.write(bary)
		f.close()
		os.system(r'start ' + file)
	else:
		print("Error\n")
		print(r.reason + ', ' + r.text)
 
#------------------------------------
# Get CrashHistory of a SIP project
# sip_id is needed
#------------------------------------		
def GetSIPCrashHistoryPDF(sip_id, fr, to):	
	_url = _api_url + "Crash/GetSIPCrashHistoryPDF?sip_id=" + str(sip_id) + "&from="+fr +"&to="+to;
	r = requests.get(_url, headers=_api_hdr)
	if(r.ok):
		
		os.chdir(".")
		file = os.getcwd() + "\\" +  str(sip_id) + ".pdf"
		print("PDF File " , file)
		f = open(file, "wb")
		bary = bytearray(r.content)
		f.write(bary)
		f.close()
		os.system(r'start ' + file)
	else:
		print("Error\n")
		print(r.reason + ', ' + r.text)
		
		
#-------------------
# main program.....
#-------------------
print("#=====================================")
print("# SDV 2 Samples python script")
print("# GetCrashHistory Example")
print("# Gets req_id and retrieves PDF ")
print("# GetCrashHistoryPDF Example")
print("# GetCrashHistoryExcel Example")
print("# GetSIPCrashHistoryPDF Example")
print("#=====================================")
req_id = 0
print("Executing.... Crash History")
#------------------------------------
# Get CrashHistory: NEW REQUEST
#------------------------------------
req_id = GetCrashHistory()
if req_id > 0:
	print("Fetching PDF Export file for Crash History Request ID:" + str(req_id))
	GetCrashHistoryPDF(req_id);
if req_id > 0:
	print("Fetching CSV Export file for Crash History Request ID:" + str(req_id))
	GetCrashHistoryExcel(req_id);
 
#------------------------------------
# Get CrashHistory: UPDATE REQUEST
#------------------------------------
if req_id > 0:
	print("Get updated Crash History for Request ID:" + str(req_id))
	GetCrashHistoryUpdate(req_id);
 
	print("Fetching PDF Export file for Crash History Request ID:" + str(req_id))
	GetCrashHistoryPDF(req_id);
 
#print("Getting PDF Export file for Crash History SIP Project ID:866")
#GetSIPCrashHistoryPDF(866)
	
#-------------------------------------



