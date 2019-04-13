
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

namespace IdentityManagement.Api{
    internal static class TlsHack {
        public static void Hack () {            
            // Disabling certificate validation can expose you to a man-in-the-middle attack
            // which may allow your encrypted message to be read by an attacker
            // https://stackoverflow.com/a/14907718/740639
            ServicePointManager.ServerCertificateValidationCallback =
                delegate (
                    object s,
                    X509Certificate certificate,
                    X509Chain chain,
                    SslPolicyErrors sslPolicyErrors
                ) {
                    return true;
                };
        }
    }
}