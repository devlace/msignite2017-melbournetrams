using System.IO;
using System.Globalization;
using System.Diagnostics;
using System.Linq;

using Microsoft.Azure.Management.DataFactories.Models;
using Microsoft.Azure.Management.DataFactories.Runtime;

using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using SODA;

namespace Trams.DF.ApiDownload
{
    public class ApiDownloadActivity : IDotNetActivity
    {
        private IActivityLogger _logger;
        private string appToken = "7WoqTdGEDWbjhU7O2jh9WOfFU";

        public IDictionary<string, string> Execute(
            IEnumerable<LinkedService> linkedServices, 
            IEnumerable<Dataset> datasets, 
            Activity activity, 
            IActivityLogger logger)
        {
            _logger = logger;

            #region Retrieve properties from data factory

            // to get extended properties (for example: SliceStart)
            DotNetActivity dotNetActivity = (DotNetActivity)activity.TypeProperties;
            string year = dotNetActivity.ExtendedProperties["year"];
            string month = dotNetActivity.ExtendedProperties["month"];
            string day = dotNetActivity.ExtendedProperties["day"];
            string hour = dotNetActivity.ExtendedProperties["hour"];
            string sodaUrl = dotNetActivity.ExtendedProperties["sodaUrl"];
            string resourceId = dotNetActivity.ExtendedProperties["resourceId"];

            //Retrieve blob storage output connection string
            Dataset outputDataset = datasets.Single(dataset => dataset.Name == activity.Outputs.Single().Name);
            AzureStorageLinkedService outputLinkedService = linkedServices.First(
                linkedService => linkedService.Name == outputDataset.Properties.LinkedServiceName).Properties.TypeProperties
                as AzureStorageLinkedService;
            string connectionString = outputLinkedService.ConnectionString;

            #endregion

            #region Download from API

            _logger.Write("Downloading data");
            var data = DownloadData(year, month, day, hour, sodaUrl, appToken, resourceId);
            var cleanData = data.Select(d => CleanData(d));
            var outputCsv = cleanData.ToCsv<SensorDataClean>();

            #endregion

            #region Save to Blob and Exit
            
            string folderPath = GetFolderPath(outputDataset);
            string fileName = String.Format("{0}.csv", Guid.NewGuid().ToString());

            _logger.Write("Saving data to blob with cs: {0}, folderPath: {1}, fileName: {2}", connectionString, folderPath, fileName);
            SaveDataToBlob(connectionString, folderPath, fileName, outputCsv);
            
            _logger.Write("Exit");
            return new Dictionary<string, string>();

            #endregion
        }

        private IEnumerable<SensorData> DownloadData(string year, string month, string day, string hour, string sodaUrl, string appToken, string resourceId)
        {
            var client = new SodaClient(sodaUrl, appToken);
            var dataset = client.GetResource<SensorData>(resourceId);

            var predicate = String.Format("year = {0} and month = '{1}' and mdate = {2} and time = {3}", year, month, day, hour);

            _logger.Write("Predicate: {0}", predicate);

            var soql = new SoqlQuery()
                          .Where(predicate);

            var rows = dataset.Query<SensorData>(soql);

            _logger.Write("Row count: {0}", rows.Count());

            return rows;
        }
        private SensorDataClean CleanData(SensorData data)
        {
            try
            {

                var date = DateTime.ParseExact(data.daet_time.Trim(), "dd-MMM-yyyy HH:mm", System.Globalization.CultureInfo.InvariantCulture);
                var modifiedDate = date.AddMonths(3); //for demo purposes
                var clean = new SensorDataClean()
                {
                    year = Convert.ToInt32(modifiedDate.ToString("yyyy")),
                    month = modifiedDate.ToString("MMMM"),
                    month_num = Convert.ToInt32(modifiedDate.ToString("%M")),
                    mdate = Convert.ToInt32(modifiedDate.ToString("%d")),
                    day = modifiedDate.ToString("dddd"),
                    hour = Convert.ToInt32(modifiedDate.ToString("%H")),
                    date_time = modifiedDate.ToString("yyyy-MM-dd HH:mm:ss"),
                    sensor_id = data.sensor_id,
                    sensor_name = data.sensor_name,
                    hourly_counts = Convert.ToInt32(data.qv_market_peel_st.Trim())

                };
                return clean;
            }
            catch(Exception ex)
            {
                _logger.Write("Error while cleaning data: {0}. Data: {1}", ex.Message, data.ToCsvValue<SensorData>());
            }
            return new SensorDataClean();
        }
        private void SaveDataToBlob(string connectionString, string folderPath, string fileName, string text)
        {
            _logger.Write("Writing {0} to the output blob", text);
            
            CloudStorageAccount outputStorageAccount = CloudStorageAccount.Parse(connectionString);
            Uri outputBlobUri = new Uri(outputStorageAccount.BlobEndpoint, folderPath + "/" + fileName);
            CloudBlockBlob outputBlob = new CloudBlockBlob(outputBlobUri, outputStorageAccount.Credentials);
            outputBlob.UploadText(text);
        }

        /// <summary>
        /// Gets the folderPath value from the input/output dataset.
        /// </summary>
        private static string GetFolderPath(Dataset dataArtifact)
        {
            if (dataArtifact == null || dataArtifact.Properties == null)
            {
                return null;
            }

            AzureBlobDataset blobDataset = dataArtifact.Properties.TypeProperties as AzureBlobDataset;
            if (blobDataset == null)
            {
                return null;
            }

            return blobDataset.FolderPath;
        }

        /// <summary>
        /// Gets the fileName value from the input/output dataset.   
        /// </summary>
        private static string GetFileName(Dataset dataArtifact)
        {
            if (dataArtifact == null || dataArtifact.Properties == null)
            {
                return null;
            }

            AzureBlobDataset blobDataset = dataArtifact.Properties.TypeProperties as AzureBlobDataset;
            if (blobDataset == null)
            {
                return null;
            }

            return blobDataset.FileName;
        }
        
    }
}
