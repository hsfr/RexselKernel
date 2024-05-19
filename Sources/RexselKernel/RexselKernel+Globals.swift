//
//  RexselKernel+Globals.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
/// Show the line number on the output.
var showLineNumbers: Bool = false

var showUndefinedErrors: Bool = false

var showSymbolTable: Bool = false

var showErrors: Bool = false

var showFullMessages: Bool = false

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
/// Determines whether there should be a prefix to the output element.
///
/// It is normally _false_ but can be changed in the command line using
/// the "-noXmlnsPrefix".
var useDefaultXSLNamespace: Bool = false

#if REXSEL_LOGGING
    var rLogger = RexselLogger()
#endif
