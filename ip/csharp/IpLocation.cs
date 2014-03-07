using System;
using System.IO;
using System.Text;

namespace IpLocation
{
    public class IpLocation
    {
        readonly string ipBinaryFilePath = "17monipdb.dat";
        readonly byte[] dataBuffer, indexBuffer;
        readonly int[] index = new int[256];
        readonly int offset;
        public IpLocation()
        {
            try
            {
                FileInfo file = new FileInfo(ipBinaryFilePath);
                dataBuffer = new byte[file.Length];
                using (var fin = new FileStream(file.FullName, FileMode.Open, FileAccess.Read))
                {
                    fin.Read(dataBuffer, 0, dataBuffer.Length);
                }

                var indexLength = BytesToLong(dataBuffer[0], dataBuffer[1], dataBuffer[2], dataBuffer[3]);
                indexBuffer = new byte[indexLength];
                Array.Copy(dataBuffer, 4, indexBuffer, 0, indexLength);
                offset = (int)indexLength;

                for (int loop = 0; loop < 256; loop++)
                {
                    index[loop] = (int)BytesToLong(indexBuffer[loop * 4 + 3], indexBuffer[loop * 4 + 2], indexBuffer[loop * 4 + 1], indexBuffer[loop * 4]);
                }
            }
            catch { }
        }
        private static long BytesToLong(byte a, byte b, byte c, byte d)
        {
            return (a << 24) | (b << 16) | (c << 8) | d;
        }
        public string[] Find(string ip)
        {
            var ips = ip.Split('.');
            int ip_prefix_value = int.Parse(ips[0]);
            long ip2long_value = BytesToLong(byte.Parse(ips[0]), byte.Parse(ips[1]), byte.Parse(ips[2]), byte.Parse(ips[3]));
            int start = index[ip_prefix_value];
            int max_comp_len = offset - 1028;
            long index_offset = -1;
            int index_length = -1;
            byte b = 0;
            for (start = start * 8 + 1024; start < max_comp_len; start += 8)
            {
                if (BytesToLong(indexBuffer[start + 0], indexBuffer[start + 1], indexBuffer[start + 2], indexBuffer[start + 3]) >= ip2long_value)
                {
                    index_offset = BytesToLong(b, indexBuffer[start + 6], indexBuffer[start + 5], indexBuffer[start + 4]);
                    index_length = 0xFF & indexBuffer[start + 7];
                    break;
                }
            }
            var areaBytes = new byte[index_length];
            Array.Copy(dataBuffer, offset + (int)index_offset - 1024, areaBytes, 0, index_length);
            return Encoding.UTF8.GetString(areaBytes).Split('\t');
        }
    }
}