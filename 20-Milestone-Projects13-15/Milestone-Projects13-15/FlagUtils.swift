//
//  FlagUtils.swift
//  Milestone-Projects13-15
//

import Foundation

let prefixSD = "flag_sd_"
let prefixHD = "flag_hd_"
let flagExt = ".png"

func getFlagFileName(code: String, type: FlagType) -> String {
    return getFlagPrefix(type: type) + code + flagExt
}

func getFlagPrefix(type: FlagType) -> String {
    switch(type) {
    case .HD:
        return prefixHD
    case .SD:
        return prefixSD
    }
}

enum FlagType {
    case HD
    case SD
}
