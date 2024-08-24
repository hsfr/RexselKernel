//
//  RexselKernel+Types.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

typealias AllowableSyntaxDictType = [ String: AllowableSyntaxEntryStruct ]

typealias XmlnsSymbolTableType = [ String: Int ]

var xPathVariablePattern: String = "\\$[a-zA-Z_]([a-zA-Z0-9_\\-]+[a-zA-Z0-9])?"

var simpleVariablePattern: String = "[a-zA-Z_]([a-zA-Z0-9_\\-]+[a-zA-Z0-9])?"


