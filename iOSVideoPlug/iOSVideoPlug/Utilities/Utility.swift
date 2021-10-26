//
//  Utility.swift
//  iOSVideoPlug
//
//  Created by Rahul Panzade on 02/04/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import Foundation

// Alert view messages and titles
let EXCEED_TITLE = "Oops"
let EXCEED_MSG = "Video size must not be greater than/up to 50MB"

let WARNING_TITLE = "Oops!"
let CATEGORY_REQUIRED_MSG = "Category can not be blank."
let NAME_REQUIRED_MSG = "Name can not be blank."
let SOMETHING_WENT_WRONG_MSG = "Something went wrong. Try later."

let FAILURE_TITLE = "Oops"
let NOINTERNET_TITLE = "No Internet !"
let NOINTERNET_MESSAGE = "No internet available. Please check your connection."

let DOWNLOADING_IN_PROGRESS = "Downloading of this video already in progress."

let DELETE_VIDEO_TITLE = "Delete!"
let DELETE_DOWNLOADING_VIDEO_MSG = "Are you sure to delete this downloaded video."

let DONT_HAVE_OFFLINE_DATA_TITLE = "Empty!"
let DONT_HAVE_OFFLINE_DATA_MSG = "Sorry, You do not have any downloaded video"

// Pagination count
let PER_PAGE_TAKE_COUNT = 20

// URL Paths
let UPLOAD_VIDEO_PATH = "api/video/upload"
let GET_VIDEO_LIST_PATH = "api/video/getvideolist"

// Notification names
let REACHABILITY_NOTIF_NAME = "ReachabilityChangedToOffline"
let DOWNLOAD_PAUSE_NOTIF_NAME = "DownloadingPuased"
let REFRESH_HOMEVIEW_NOTIF_NAME = "RefreshHomeViewListData"

// Offline video download Directory name
let DOWNLOAD_DIRECTORY = "PlugableOfflineVideo"
