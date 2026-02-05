@model MesTAManagementSystem_New.ViewModels.DLOperation.Checking.SubjectiveVM
@{
    ViewBag.Title = "Objective(客觀評比排名作業)";
    Layout = "~/Views/Shared/_LayoutMainWithBasic.cshtml";
}

@section scripts
{
    @Scripts.Render("~/bundles/jquery-ui")
    @Scripts.Render("~/bundles/jqgrid")
    @Scripts.Render("~/bundles/jquery-blockui")

    <script type="text/javascript">
        var $resultTable = $('#result-table');
        var $submitButton = $('#submit-button');
        var $saveButton = $('#save-button');

        $(document).ready(function () {
            // [表格設定]
            $resultTable.jqGrid({
                datatype: 'local',
                autowidth: true,
                shrinkToFit: false,
                height: $('div.main').height() - 150,
                colNames: ['部門', '站別', '班別', '工號', '姓名', '職等群組', '職稱', '考核次數', 'Comments'],
                colModel: [
                    { name: 'Dept_Id', width: 70 },
                    { name: 'Station_Id', width: 70 },
                    { name: 'Shift_Id', width: 60 },
                    { name: 'Emp_Id', width: 70, key: true },
                    { name: 'Name', width: 70 },
                    { name: 'Position_Group', width: 80 },
                    { name: 'Title', width: 100 },
                    { name: 'Rankinga', width: 70, editable: true }, // 次數
                    { name: 'Comments', width: 200, editable: true } // 備註
                ],
                cellEdit: true,
                cellsubmit: 'clientArray',
                pager: '#result-table-pager'
            });

            //===================================================================================
            //  連動式下拉選單邏輯 (Cascading Dropdown)
            //===================================================================================
            $("#Item").change(function () {
                var selectedItem = $(this).val();
                var $detailSelect = $("#DetailItem");

                // 清空細項選單
                $detailSelect.empty().append($('<option>', { value: "", text: "請選擇" }));

                if (selectedItem) {
                    $.post('@Url.Action("GetDetailItems")', {
                        stationId: $("#Station_Id").val(),
                        title: $("#Title").val(),
                        item: selectedItem
                    }, function (data) {
                        $.each(data, function (i, val) {
                            $detailSelect.append($('<option>', { value: val.Value, text: val.Text }));
                        });
                    });
                }
            });

            // [查詢按鈕]
            $submitButton.click(function () {
                var vm = getFormData();
                $.ajax({
                    url: '@Url.Action("QueryObjectiveTable")',
                    type: 'POST',
                    data: JSON.stringify(vm),
                    contentType: 'application/json',
                    beforeSend: function () { $.blockUI(); },
                    success: function (data) {
                        if (data.error) alert(data.error);
                        else $resultTable.jqGrid('clearGridData').jqGrid('setGridParam', { data: data }).trigger('reloadGrid');
                    },
                    complete: function () { $.unblockUI(); }
                });
            });

            // [存檔按鈕]
            $saveButton.click(function () {
                if(!confirm('確定存檔？')) return;
                
                var gridData = $resultTable.jqGrid('getGridParam', 'data');
                var vm = getFormData();

                $.ajax({
                    url: '@Url.Action("SaveObjectiveData")',
                    type: 'POST',
                    data: JSON.stringify({ vm: vm, dataList: gridData }),
                    contentType: 'application/json',
                    success: function (res) {
                        if(res.success) alert('存檔完成');
                        else alert('失敗：' + res.message);
                    }
                });
            });

            function getFormData() {
                return {
                    Year: $("#Year").val(), Month: $("#Month").val(), Dept_Id: $("#Dept_Id").val(),
                    Title: $("#Title").val(), Station_Id: $("#Station_Id").val(),
                    Item: $("#Item").val(), DetailItem: $("#DetailItem").val()
                };
            }
        });
    </script>
}

@section left_sidebar
{
    <form id="search-form">
        <table width="100%">
            <thead><tr><th colspan="2"><i class="glyphicon glyphicon-search"></i> 客觀績效查詢</th></tr></thead>
            <tbody>
                <tr><td align="right">年度：</td><td>@Html.DropDownListFor(m => m.Year, Model.YearList, new { @class = "form-control input-xs" })</td></tr>
                <tr><td align="right">月份：</td><td>@Html.DropDownListFor(m => m.Month, Model.MonthList, new { @class = "form-control input-xs" })</td></tr>
                <tr><td align="right">部門：</td><td>@Html.TextBoxFor(m => m.Dept_Id, new { @class = "form-control input-xs", @readonly = "readonly" })</td></tr>
                <tr><td align="right">職稱：</td><td>@Html.DropDownListFor(m => m.Title, Model.TitleList, new { @class = "form-control input-xs" })</td></tr>
                <tr><td align="right">站別：</td><td>@Html.TextBoxFor(m => m.Station_Id, new { @class = "form-control input-xs", @readonly = "readonly" })</td></tr>
                <tr><td align="right">項目：</td><td>@Html.DropDownListFor(m => m.Item, Model.ItemList, new { @class = "form-control input-xs" })</td></tr>
                <tr><td align="right">細項：</td><td>@Html.DropDownListFor(m => m.DetailItem, Model.DetailItemList, new { @class = "form-control input-xs" })</td></tr>
                <tr>
                    <td></td>
                    <td>
                        <button id="submit-button" type="button" class="btn btn-xs btn-primary">Search</button>
                        <button id="save-button" type="button" class="btn btn-xs btn-success">Save</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </form>
}

<table id="result-table"></table>
<div id="result-table-pager"></div>
