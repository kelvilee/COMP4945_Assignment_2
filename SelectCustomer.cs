using System;
using System.Data.Odbc;
using System.IO;
using System.Drawing;
using System.Windows.Forms;

// Code by Kelvin
namespace selectCustomer
{
    class Program
    {
        //Displaying Image 

        public static Bitmap ByteToImage(byte[] blob)
        {
            MemoryStream mStream = new MemoryStream();
            byte[] pData = blob;
            mStream.Write(pData, 0, Convert.ToInt32(pData.Length));
            Bitmap bm = new Bitmap(mStream, false);
            mStream.Dispose();
            return bm;
        }

        static void Main(string[] args)
        {
            // Connection
            string connectionString = "DSN=mySqlServer;Uid=SYSTEM;Pwd=password";
            OdbcConnection conn = new OdbcConnection();
            conn = new OdbcConnection(connectionString);
            conn.Open();
            //reading from an RDBMS via ODBC.  Note the use of isDBNull, use it for  
            string query = "SELECT ID, Name, Birthdate, Picture FROM Customer ORDER BY ID";
            OdbcCommand exe = new OdbcCommand(query, conn);
            OdbcDataReader read = exe.ExecuteReader();
            byte[] contentDataBuffer = new byte[2097125]; // 2 MB - 
            while (read.Read())
            {
                string tmpUid = (read.GetInt64(0)).ToString();
                string tmpName = read.IsDBNull(1) == false ? read.GetString(1) : null;
                DateTime tmpBirthDate = read.GetDateTime(2);

                long lCntRead = read.GetBytes(3, 0, contentDataBuffer, 0, 2097125);
            }
            Form1 form = new Form1();
            form.ShowMyImage(ByteToImage(contentDataBuffer)); // byteArr holds byte array value, display image in Form
        }
    }
}
