using System;
using System.Collections.Generic;
using System.Web.Mvc;
using Newtonsoft.Json;
using System.Data;
using System.IO;
using MXIC.MIT.Common;
using MXIC.MIT.Common.Office;
using MesTAManagementSystem_New.Models.Training.Testing;
using MesTAManagementSystem_New.Models;
using MesTAManagementSystem_New.ViewModels.DLOperation.Checking;
using MesTAManagementSystem_New.Services;
using MesTAManagementSystem_New.Repositories;
using System.Linq;

namespace MesAccMgm.Controllers.QueryData
{
    public class ObjectiveController : Controller
    {
        //
        // GET: /PCDLifeTimeHistory/

        private readonly BaseRepository _baseRepository;
        private readonly ReportService _reportService;
        private string userId = string.Empty;
        private string SESGroup = string.Empty;

        public ObjectiveController()
        {
            this._baseRepository = new BaseRepository();
            this._reportService = new ReportService();
            UserDataModel userData = ((UserDataModel)System.Web.HttpContext.Current.Session["User"]);
            this.userId = userData != null ? userData.UserId : string.Empty;
            this.SESGroup = userData != null ? userData.SESGroup : string.Empty;
        }

        public ActionResult Index()
        {
            SubjectiveVM vm = new SubjectiveVM();
            string year = string.Empty;
            string month = string.Empty;
            #region year and month
            var GetYearList = _reportService.GetSubjectiveYear();
            vm.YearList = GetYearList.Select(x => new SelectListItem
            {
                Value = x.Year,
                Text = x.Year
            }).ToList();
            var GetMonthList = _reportService.GetSubjectiveMonth();
            vm.MonthList = GetMonthList.Select(x => new SelectListItem
            {
                Value = x.Month,
                Text = x.Month
            }).ToList();
            year = _reportService.GetCurrentDate("ym-1", -1);
            vm.Year = year;
            month = _reportService.GetCurrentDate("m", -1);
            vm.Month = month;
            #endregion
            vm.Dept_Id = _reportService.SubjectiveGetUser(userId).Select(m => m.Dept_Id).FirstOrDefault();
            var GetTitleList = _reportService.SubjectiveGetTitleList();
            vm.TitleList = GetTitleList.Select(x => new SelectListItem 
            { 
                Value = x.Title,
                Text = x.Title 
            }).ToList();
            vm.Shift_Id = _reportService.SubjectiveGetUser(userId).Select(m => m.Shift_Id).FirstOrDefault();
            vm.Station_Id = _reportService.SubjectiveGetUser(userId).Select(m => m.Station_Id).FirstOrDefault();
            vm.Title = GetTitleList.Select(m => m.Title).FirstOrDefault();
            var GetItemList = _reportService.SubjectiveGetItemList(vm.Station_Id, vm.Title);
            vm.ItemList = GetItemList.Select(x => new SelectListItem
            {
                Value = x.Item,
                Text = x.Item
            }).ToList();
            vm.Item = GetItemList.Select(m => m.Item).FirstOrDefault();
            var GetDetailItemList = _reportService.SubjectiveGetDetailItemList(vm.Station_Id, vm.Title, vm.Item);
            vm.DetailItemList = GetDetailItemList.Select(x => new SelectListItem
            {
                Value = x.DetailItem,
                Text = x.DetailItem
            }).ToList();
            vm.DetailItem = GetDetailItemList.Select(m => m.DetailItem).FirstOrDefault();
            return View(vm);
        }

        public ContentResult QueryTable(SubjectiveVM searchInfo)
        {
            var result = _reportService.GetSubjectiveData(searchInfo.Dept_Id, searchInfo.Station_Id, searchInfo.Shift_Id, searchInfo.Title);
            return Content(JsonConvert.SerializeObject(result), "application/json");
        }
    }
}
