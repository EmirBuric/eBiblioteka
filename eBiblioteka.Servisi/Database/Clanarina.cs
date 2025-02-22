using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Clanarina
{
    public int ClanarinaId { get; set; }

    public string StatusClanarine { get; set; } = null!;

    public DateTime DatumUplate { get; set; }

    public DateTime DatumIsteka { get; set; }

    public int? KorisnikId { get; set; }

    public int? TipClanarineId { get; set; }

    public virtual Korisnik? Korisnik { get; set; }

    public virtual TipClanarine? TipClanarine { get; set; }
}
