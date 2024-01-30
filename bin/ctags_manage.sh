#!/bin/bash

##################初始化全局变量区#################

#获取文件绝对路径

if [ $(echo $0 | grep '^/') ]; then
	    g_rootPath=$(dirname $0)
	else
		g_rootPath=$(pwd)/$(dirname $0)
fi
#工程根目录
g_rootPath=~/.ctags/
#入参个数
g_paramNum=$#
#工程名
g_name=$1
#执行什么
g_todo=$2
#################函数定义区###########################

CheckParameters()
{
	paramNum=$1
	name=$2
	todo=$3
	
	if [ $paramNum -eq 0 ]; then
		echo "please input object name. like:"
		echo "vo name"
		exit
	fi

#	grep "name=" .configure | grep $name > /dev/null
#	if [ $? -eq 1 ]; then # 为1表示没有这个name	
#		if [ ! -d $name ]; then
#			echo "input error"
#			exit
#		fi
#	fi

	if [ $paramNum -gt 1 ]; then
		if [[ "$todo" != "update" && "$todo" != "clean" && "$todo" != "config" ]]; then
			echo "input todo error"
			exit
		fi
	fi
}

CreateObject()
{
	name=$1
	if [ ! -d $name ]; then
		mkdir -p $name
		touch $name/run.sh
		chmod +x $name/run.sh
        echo "name=\"$name\"" > $name/run.sh
        echo "g_rootPath=$g_rootPath" >> $name/run.sh
        cat $g_rootPath/.template >> $name/run.sh

		sed -i  "s/name=\".*\"/name=\"${name}\"/g" $g_rootPath/.configure

		cp $g_rootPath/.configure $name/configure	
		return
	fi
}

ObjectConfig()
{
	name=$1
	vi $name/configure
	

	exit
}
ObjectAddFile()
{
    name=$1
    echo "filePath+=\"$PWD \"" >> $g_rootPath/objs/$name/configure
    echo "filePath+=\"$PWD \""
}

RunOldObject()
{	
	name=`grep "name=\"" $g_rootPath/link/configure`
	if [ "$name" == "name=\"\"" ]; then
		echo "nothing object"
	fi
	name=${name#*\"}
	name=${name%*\"}
	if [ ! -d $name  ]; then
		echo "nothing object"
        exit
	fi
    echo "curr obj is $name"
	$name/run.sh
	exit
}
Delete()
{
	name=$1
	rm -rf $name
    echo "delete object $name"
	exit
}
RunPath()
{
    name=$1
    path=$2
    echo "change object $name run path to $path"
    sed -i "s|runPath=\".*\"|runPath=\"${path}\"|g" $g_rootPath/link/configure
    $g_rootPath/link/run.sh
}
main()
{
	paramNum=$1
	name=$2
	todo=$3
    #echo paramNum=$paramNum
    #echo name=$name
    #echo todo=$todo

	cd $g_rootPath/objs
	CreateObject $name
    cd - >> /dev/null

    # 添加项目目录pwd
	if [ "$todo" == "add" ]; then
        ObjectAddFile $name
        exit 0
    fi
    # 修改运行路径
	if [ "$todo" == "run" ]; then
		RunPath $name $PWD
        exit 0
    fi

    cd - >> /dev/null
    # 无参数就运行之前打开的工程
	if [ $paramNum -eq 0 ] || [ "$name" == ""  ]; then
		RunOldObject
	fi
	#CheckParameters $paramNum $name $todo
	# 删除工程
	if [ "$todo" == "delete" ]; then
		Delete $name	
        exit 0
	fi
    # 配置工程
	if [ "$todo" == "config" ]; then
		ObjectConfig $name	
        exit 0
	fi 
    # 更新工程，刷新tag，cscope
	if [ "$todo" == "update" ]; then
        echo "update object $name tags"
        $name/run.sh $todo
        exit 0
	fi 
	
    $name/run.sh $todo

}

################函数调用区###################
main $g_paramNum $g_name $g_todo
