function highlightScore(ELMT_ID)
{
	var elmt = document.getElementById(ELMT_ID);
	elmt.className = "score_hover";
}

function unhighlightScore(ELMT_ID)
{
	var elmt = document.getElementById(ELMT_ID);
	elmt.className = "score";
}

function deleteFiles()
{
    var index=0;
    $.ajaxSetup({async: false});
    while (index < 10000) {
        if ($("#check_" + index).length == 0) break;
        var check = $("#check_" + index)[0];
        if (check.value == "on") {
            var filename = $("#filename_" + index)[0];
            var dest = filename.href.substring(filename.baseURI.length);
            $.get(filename.baseURI + "Command/Delete?" + dest.substring(10), function(data) {});
        }
        index++;
    }
    $.get('formattedFileList.html', function(data) {$('#fileList').html(data);});
    $.get('formattedScoreCount.html', function(data) {$('#score_count').html(data);});
}
------WebKitFormBoundaryhhJUBbf0PB9nI6zf--
