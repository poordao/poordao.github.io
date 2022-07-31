#!/bin/bash

echo "========================================"
echo "-------------开始打包和发布博客-----------"
echo "========================================"
cd /Users/Fussen/Webstorm/poordao

if [ $? -ne 0 ]; then
    echo "进入博客文件夹失败"
else
    hexo clean && hexo g && hexo d 	
fi

if [ $? -ne 0 ]; then
    echo "博客编译失败"
else
    git add . && git commit -m "new" && git push origin hexo	
fi

if [ $? -ne 0 ]; then
    echo "=======博客备份失败========"
else
    echo "========================================"
	echo "------------博客发布和备份成功------------"
	echo "========================================" 	
fi

