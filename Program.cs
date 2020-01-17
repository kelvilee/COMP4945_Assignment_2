using System;
using System.Data.Odbc;
using System.IO;

class MyOdbcConnection
{
    public static void Main()
    {
        // Image src
        String newFileName  = "C:/Users/A01048343/Desktop/Images/octo.jpg";
        // //String DestinationLoc = "C:\Users\A01048343\Desktop\Images";

        //Reading from an image file
        FileStream fs = File.OpenRead(newFileName);
        Byte[] byData = new byte[fs.Length - 1];
        fs.Read(byData, 0, byData.Length);

        //inserting to RDBMS via ODBC
        try
        {
            // Connection
            string connectionString = "DSN=mySqlServer;Uid=SYSTEM;Pwd=oracle1";
            OdbcConnection conn = new OdbcConnection();
            conn = new OdbcConnection(connectionString);
            conn.Open();
            string query = "INSERT INTO Customer (ID, Name, Address, Birthdate, Gender, Picture) VALUES (?, ?, ?, ?, ?, ?)";
            OdbcCommand exe = new OdbcCommand(query, conn);

            exe.Parameters.Add("@ID", OdbcType.Int).Value = 100;
            // you can also try -  new Guid("{00000000-0000-0000-0000-000000000000}");
            exe.Parameters.Add("@Name", OdbcType.Text).Value = "John";
            exe.Parameters.Add("@Address", OdbcType.Text).Value = "123 Main St.";
            exe.Parameters.Add("@Birthdate", OdbcType.DateTime).Value = DateTime.Now;
            exe.Parameters.Add("@Gender", OdbcType.Text).Value = "M";
            exe.Parameters.Add("@Picture", OdbcType.Image, byData.Length).Value = byData;
            if (exe.ExecuteNonQuery() > 0)
            {
                conn.Close();
            }
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
        }
    }
}
