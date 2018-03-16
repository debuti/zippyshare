#!/bin/bash
# @Description: zippyshare.com file download script
# @Author: Live2x
# @URL: https://github.com/img2tab/zippyshare
# @Version: 201711120002
# @Date: 2017-11-12
# @Usage: sh zippyshare.sh url

if [ -z "${1}" ]
then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one zippyshare.com url per line"
    exit
fi

DEBUG=0

function zippydownload()
{
    ((DEBUG)) && echo "URL ${url}"
    prefix="$( echo -n "${url}" | cut -c "11,12,31-38" | sed -e 's/[^a-zA-Z0-9]//g' )"
    cookiefile="${prefix}-cookie.tmp"
    infofile="${prefix}-info.tmp"
    ((DEBUG)) && echo "prefix ${prefix}"

    # loop that makes sure the script actually finds a filename
    filename=""
    retry=0
    while [ -z "${filename}" -a ${retry} -lt 10 ]
    do
        let retry+=1
        rm -f "${cookiefile}" 2> /dev/null
        rm -f "${infofile}" 2> /dev/null
        wget -O "${infofile}" "${url}" \
        --cookies=on \
        --keep-session-cookies \
        --save-cookies="${cookiefile}" \
        --quiet
        filename="$( cat "${infofile}" | grep "/d/" | cut -d'/' -f5 | cut -d'"' -f1 | grep -o "[^ ]\+\(\+[^ ]\+\)*" )"
    done

    ((DEBUG)) && echo "filename ${filename}"

    if [ "${retry}" -ge 10 ]
    then
        echo "could not download file"
        exit
    fi

    ((DEBUG)) && cat "${cookiefile}" 

    # Get cookie
    if [ -f "${cookiefile}" ]
    then 
        jsessionid="$( cat "${cookiefile}" | grep "JSESSIONID" | cut -f7)"
    else
        echo "can't find cookie file for ${prefix}"
        exit
    fi

    ((DEBUG)) && echo "jsessionid ${jsessionid}"

    if [ -f "${infofile}" ]
    then
	var_a=$(cat "${infofile}" | perl -n -e '/var a = (\d+);/ && print $1')
	((DEBUG)) && echo "var_a $var_a"
	subs_0=$(cat "${infofile}"  | grep omg | perl -n -e '/substr\((\d+)/ && print $1')
        ((DEBUG)) && echo "subs_0 $subs_0"
	subs_1=$(cat "${infofile}"  | grep omg | perl -n -e '/substr\((\d+), (\d+)/ && print $2')
        ((DEBUG)) && echo "subs_1 $subs_1"
	let var_b=$subs_1-$subs_0
        ((DEBUG)) && echo "var_b $var_b"
	pow=$(cat "${infofile}" | grep dlbutton | grep href | perl -n -e '/Math\.pow\(a, (\d+)\)/ && print $1')
        ((DEBUG)) && echo "pow $pow"
	a=$(($var_a ** $pow + $var_b)) 
        ((DEBUG)) && echo "a $a"

        # Get ref, server, id
        ref="$( cat "${infofile}" | grep 'property="og:url"' | cut -d'"' -f4 | grep -o "[^ ]\+\(\+[^ ]\+\)*" )"
	((DEBUG)) && echo "ref ${ref}"

        server="$( echo "${ref}" | cut -d'/' -f3 )"
	((DEBUG)) && echo "server ${server}"

        id="$( echo "${ref}" | cut -d'/' -f5 )"
	((DEBUG)) && echo "id ${id}"

    else
        echo "can't find info file for ${prefix}"
        exit
    fi

    # Build download url
    dl="http://${server}/d/${id}/${a}/${filename}"
    ((DEBUG)) && echo "dl ${dl}"

    # Set brower agent
    agent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"

    echo "${filename}"

    # Start download file
    wget -c -O "${filename}" "${dl}" \
    -q --show-progress \
    --referer="${ref}" \
    --cookies=off --header "Cookie: JSESSIONID=${jsessionid}" \
    --user-agent="${agent}"

    ((DEBUG)) || rm -f "${cookiefile}" 2> /dev/null
    ((DEBUG)) || rm -f "${infofile}" 2> /dev/null
}

if [ -f "${1}" ]
then
    for url in $( cat "${1}" | grep -i 'zippyshare.com' )
    do
        zippydownload "${url}"
    done
else
    url="${1}"
    zippydownload "${url}"
fi
