//
//  main.swift
//  Basic
//
//  Created by Keith Irwin on 5/9/18.
//

import WebDevTool

let tool = WebdevTool()

do {
  try tool.run()
} catch {
  print("ERROR: \(error)")
}
