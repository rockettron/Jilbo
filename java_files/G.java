import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.*;

class G {
    private Random r = new SecureRandom();
    private BigInteger a = BigInteger.ONE;
    private BigInteger b = a.not().negate();
    private BigInteger c = b64("colkS9mK4RbMeNDrADzZGZXT+yuLsnjh61O2f0UbEtTHoXw6+lM5/vUcAVoRBFZoXFgnV6fB2bBeJg3gfX9HgdcB+qHceVmHTK2muSHtMBb8fle0RtownL+c7O32MojpJfrVUJhUUC5MZMoOleiTn76f8c/vLaOp+O9YDUtn7BU=");
    private BigInteger d = b64("Mz6nEA4534romONrMuDOQJ8riRKCUMadfWcsse37400D7iQAVZBa+nRHZuS0Q19v1WOZvBB5ZLsPGZFVnMkK6SWpsDgIlTFJO5MS2kQ4xI3gu54PywqawphIm8F47yMKmooD3tyS3nkIvc0EIea9FBSlKdRuy1JMFSUCc8p17EemKT2zZNgraihVwJhgXRJxmi8Wybz6siXWoAr66AmTXpydYabT04Uguv9YuGtiK+KMiO5FEK0gb4JJOF8jajfN+T3fwzHxZCLjhVVr5GaU/5S588Dng4Cf7rapZyoQQIsvo7FeezWDjIa2s+YAxQl/OlGrQWRvu7WwSHimIJy5uQ==");
    private BigInteger e = e();
    private BigInteger f = b.not().negate();
    private BigInteger g = BigInteger.ZERO;

    private BigInteger b64(String x) {
        return new BigInteger(Base64.getDecoder().decode(x));
    }

    private BigInteger e() {
        BigInteger t = BigInteger.ZERO;
        while (t.equals(BigInteger.ZERO)) t = new BigInteger(1000, r);
        return t.modPow(c, d);
    }

    public BigInteger next() {
        e = e.multiply(e()).multiply(c.add(a).modPow(b,d)).mod(d);
        if (g.mod(d.add(f).mod(c.subtract(b))).multiply(g.mod(c.mod(f.modPow(b,c))).subtract(b)).equals(BigInteger.ZERO))
            e = e.modPow(c.subtract(a),d);
        e = e.multiply(e()).mod(d);
        g = g.add(a);
        return e;
    } 
}