class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "http://www.freetds.org/"
  url "http://www.freetds.org/files/stable/freetds-1.00.87.tar.bz2"
  mirror "https://fossies.org/linux/privat/freetds-1.00.87.tar.bz2"
  sha256 "7408e5a7bc85f2dd53e3ddb43d5923c93103906ae0917e187a7bb687ac175576"

  bottle do
    sha256 "13ee2682501868311eb3091047c5a5d6f68474a9c3a3b67114d1ff05006d00e6" => :high_sierra
    sha256 "cd903192b191e9e3fbbb8ca4466e2ec1a71c40ddd212a688bed256e13dee86e6" => :sierra
    sha256 "07a3e4cfadb0ec32e05cfae695541542dd495e0161f797e26cb505c066f896bd" => :el_capitan
  end

  head do
    url "https://github.com/FreeTDS/freetds.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  option "with-msdblib", "Enable Microsoft behavior in the DB-Library API where it diverges from Sybase's"
  option "with-sybase-compat", "Enable close compatibility with Sybase's ABI, at the expense of other features"
  option "with-odbc-wide", "Enable odbc wide, prevent unicode - MemoryError's"
  option "with-krb5", "Enable Kerberos support"

  deprecated_option "enable-msdblib" => "with-msdblib"
  deprecated_option "enable-sybase-compat" => "with-sybase-compat"
  deprecated_option "enable-odbc-wide" => "with-odbc-wide"
  deprecated_option "enable-krb" => "with-krb5"

  depends_on "pkg-config" => :build
  depends_on "unixodbc" => :optional
  depends_on "libiodbc" => :optional
  depends_on "openssl" => :recommended

  def install
    if build.with?("unixodbc") && build.with?("libiodbc")
      odie "freetds: --without-libiodbc must be specified when using --with-unixodbc"
    end

    args = %W[
      --prefix=#{prefix}
      --with-tdsver=7.3
      --mandir=#{man}
      --sysconfdir=#{etc}
    ]

    if build.with? "openssl"
      args << "--with-openssl=#{Formula["openssl"].opt_prefix}"
    end

    if build.with? "unixodbc"
      args << "--with-unixodbc=#{Formula["unixodbc"].opt_prefix}"
    end

    if build.with? "libiodbc"
      args << "--with-libiodbc=#{Formula["libiodbc"].opt_prefix}"
    end

    # Translate formula's "--with" options to configuration script's "--enable"
    # options
    %w[msdblib sybase-compat odbc-wide krb5].each do |option|
      args << "--enable-#{option}" if build.with? option
    end

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make"
    ENV.deparallelize # Or fails to install on multi-core machines
    system "make", "install"
  end

  test do
    system "#{bin}/tsql", "-C"
  end
end
