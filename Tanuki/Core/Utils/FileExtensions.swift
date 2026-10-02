//
//  FileExtensions.swift
//  Tanuki
//
//  Created by Felix Schindler on 07.04.24.
//

import Foundation

struct Formats {
	static let audioFormats = [
		"mp3", "wav", "flac", "ogg", "m4a", "wma", "aac", "aiff", "alac", "dsd", "pcm", "mp2",
		"mp1", "mka", "opus", "ra", "rm", "sln", "vox", "weba", "wv", "8svx", "cda", "dss", "dvf",
		"gsm", "m3u", "m4b", "m4p", "m4r", "mid", "midi", "mod", "msv", "oga", "ra", "rm", "s3m",
		"sib", "sid", "wma", "xm", "aif", "aifc", "au", "snd", "voc", "w64", "wv", "wvp", "wvq",
		"wvc",
	]
	static let videoFormats = ["mp4", "mov", "avi", "mkv"]
	static let imageFormats = [
		"jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "heic", "heif",
	]
	static let pdfFormats = ["pdf"]
	static let binaryFormats = [
		"bin", "lockb", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "exe", "app", "msi", "apk",
		"jar", "zip", "tar", "gz", "7z", "rar", "iso", "dmg", "pkg", "deb", "rpm", "xz",
	]
}
