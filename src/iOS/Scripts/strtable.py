#! /usr/bin/python
# -*- coding: utf-8 -*-

import os
import re

hamcoreDir = "../bin/hamcore/"
hamcoreLang = "strtable_{}.stb"
resourcesDir = "Resources/"
resourcesName = "Localizable.strings"
resourcesLocal = resourcesDir + "{}.lproj/" + resourcesName
re_lang = re.compile("strtable_(\w{2}).stb")
re_word = re.compile("^\w")
re_sym = re.compile("^(\w+)\s+(.+)$")
re_cmd = re.compile("^PREFIX")
re_quo = re.compile("(\")")
os.chdir("/Users/shuyi/Files/SoftEtherVPN/src/iOS")


def main():
    for f in os.listdir(hamcoreDir):
        if os.path.isfile(hamcoreDir+f):
            m = re_lang.match(os.path.basename(f))
            if not m:
                continue


            read = open(hamcoreDir+f,"r",encoding="utf-8")


            filename = resourcesLocal.format(m.group(1))
            try:
                os.makedirs(os.path.dirname(filename))
            except FileExistsError as e:
                pass
            out = open(filename,"w+",encoding="utf-8")

            for line in read:
                if not re_word.match(line):
                    continue
                if re_cmd.match(line):
                    break
                m = re_sym.match(line)
                key = m.group(1)
                value = re_quo.sub("\\\"", m.group(2))
                out.write("\"{}\"=\"{}\";\n".format(key,value)) 
                
                pass
            read.close()
            out.close()

 



if __name__ == "__main__":
    # execute only if run as a script
    main()