import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

class IpLocation {
    static String ipBinaryFilePath = "f:\\loveapp\\codebase\\17mon\\17monipdb.dat";
    static File file = new File(ipBinaryFilePath);
    static ByteBuffer dataBuffer = ByteBuffer.allocate(new Long(file.length()).intValue());
    static FileInputStream fin;
    static ByteBuffer indexBuffer;
    static int offset;
    static int[] index = new int[256];
    static {
         try {
             fin = new FileInputStream(file);
             int readBytesLength;
             byte[] chunk = new byte[4096];
             while (fin.available() > 0) {
                 readBytesLength = fin.read(chunk);
                 dataBuffer.put(chunk, 0, readBytesLength);
             }
             dataBuffer.position(0);
             int indexLength = dataBuffer.getInt();
             byte[] indexBytes = new byte[indexLength];
             dataBuffer.get(indexBytes, 0, indexLength - 4);
             indexBuffer = ByteBuffer.wrap(indexBytes);
             indexBuffer.order(ByteOrder.LITTLE_ENDIAN);
             offset = indexLength;

             int loop = 0;
             while (loop++ < 256) {
                 index[loop - 1] = indexBuffer.getInt();
             }
             indexBuffer.order(ByteOrder.BIG_ENDIAN);
         } catch (IOException ioe) {
            //
         } finally {
            try {fin.close();} catch (IOException e){
            //
            }
         }
    }

    public String[] find(String ip){
        int ip_prefix_value = new Integer(ip.substring(0, ip.indexOf(".")));
        long ip2long_value  = ip2long(ip);
        int start = index[ip_prefix_value];
        int max_comp_len = offset - 1028;
        long tmpInt;
        long index_offset = -1;
        int index_length = -1;
        byte b = 0;
        for (start = start * 8 + 1024; start < max_comp_len; start += 8) {
            tmpInt = int2long(indexBuffer.getInt(start));
            if (tmpInt >= ip2long_value) {
                index_offset = bytesToLong(b, indexBuffer.get(start + 6), indexBuffer.get(start + 5), indexBuffer.get(start + 4));
                index_length = 0xFF & indexBuffer.get(start + 7);
                break;
            }
        }

        dataBuffer.position(offset + (int)index_offset - 1024);
        byte[] areaBytes = new byte[index_length];
        dataBuffer.get(areaBytes, 0, index_length);

        return new String(areaBytes).split("\t");
    }

    public static long bytesToLong(byte a, byte b, byte c, byte d) {
        return int2long((((a & 0xff) << 24) | ((b & 0xff) << 16) | ((c & 0xff) << 8) | (d & 0xff)));
    }
    private static int str2Ip(String ip)  {
        String[] bytes = ip.split("\\.");
        int a, b, c, d;
        a = stringToInt(bytes[0]);
        b = stringToInt(bytes[1]);
        c = stringToInt(bytes[2]);
        d = stringToInt(bytes[3]);
        return (a << 24) | (b << 16) | (c << 8) | d;
    }

    private static int stringToInt(String s) {
        return Integer.parseInt(s);
    }

    private static long ip2long(String ip)  {
        int ipNum = str2Ip(ip);
        return int2long(ipNum);
    }

    private static long int2long(int i) {
        long l = i & 0x7fffffffL;
        if (i < 0) {
            l |= 0x080000000L;
        }
        return l;
    }
}