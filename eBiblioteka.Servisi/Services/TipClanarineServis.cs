using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Services
{
    public class TipClanarineServis : BaseServis<TipClanarineDTO, TipClanarineSearchObject, TipClanarine>, ITipClanarineServis
    {
        public TipClanarineServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
