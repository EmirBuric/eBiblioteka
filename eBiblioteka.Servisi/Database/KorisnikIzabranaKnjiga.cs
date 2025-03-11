using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class KorisnikIzabranaKnjiga
{
    public int KorisnikIzabranaKnjigaId { get; set; }

    public int KnjigaId { get; set; }

    public int KorisnikId { get; set; }

    public bool IsChecked { get; set; }

    public DateTime DatumRezervacije { get; set; }

    public DateTime DatumVracanja { get; set; }

    public virtual Knjiga? Knjiga { get; set; }

    public virtual Korisnik? Korisnik { get; set; }
}
