package br.com.clubesocial.controller;

import br.com.clubesocial.model.Candidato;
import br.com.clubesocial.model.CandidatoStatus;
import br.com.clubesocial.service.CandidatoService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CandidatoController.class)
class CandidatoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CandidatoService service;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("Deve listar todos os candidatos")
    void deveListarCandidatos() throws Exception {
        when(service.listarTodos()).thenReturn(Arrays.asList(new Candidato(), new Candidato()));

        mockMvc.perform(get("/candidato"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2));
    }

    @Test
    @DisplayName("Deve criar um novo candidato")
    void deveCriarCandidato() throws Exception {
        Candidato candidato = new Candidato("Jose", "11122233344", "jose@email.com", null);
        when(service.salvar(any())).thenReturn(candidato);

        mockMvc.perform(post("/candidato")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(candidato)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.nome").value("Jose"));
    }

    @Test
    @DisplayName("Deve atualizar status do candidato")
    void deveAtualizarStatus() throws Exception {
        Candidato candidato = new Candidato();
        candidato.setStatus(CandidatoStatus.APROVADO);
        
        when(service.alterarStatus(any(), any())).thenReturn(candidato);

        mockMvc.perform(put("/candidato/1/status")
                .contentType(MediaType.APPLICATION_JSON)
                .content("\"APROVADO\""))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APROVADO"));
    }
}
