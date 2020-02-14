package main

import (
	"fmt"
	"os"

	"./php2go"
)

func main() {
	curPath, _ := os.Getwd()
	fmt.Println(curPath)
	content, err := php2go.FileGetContents(curPath + "/package.ini")
	if err != nil {
		panic(err)
	}
	content = php2go.StrReplace("\r\n", "\n", content, -1)
	content = php2go.StrReplace("\r", "\n", content, -1)
	fmt.Println(content)
}
